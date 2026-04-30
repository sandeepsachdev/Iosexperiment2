import Foundation
import Combine

@MainActor
final class OpenSkyService: ObservableObject {
    @Published var aircraft: [Aircraft] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?

    // Route cache: icao24 → route (nil means "no route found")
    @Published var routes: [String: FlightRoute] = [:]
    private var routeLoading: Set<String> = []
    
    // Alternative flight data service
    private let aviationStack = AviationStackService()
    
    // Rate limiting for route requests
    private var lastRouteRequest: Date?
    private let minimumRouteRequestInterval: TimeInterval = 2.0 // 2 seconds between route requests

    private var refreshTask: Task<Void, Never>?
    private let refreshInterval: TimeInterval = 15

    // Bounding box around Sydney Airport (roughly 150 km radius)
    private let lamin = -35.5, lamax = -32.5
    private let lomin = 149.5, lomax = 152.5

    func startTracking() {
        fetchAircraft()
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
                if !Task.isCancelled { fetchAircraft() }
            }
        }
    }

    func stopTracking() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func fetchAircraft() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let urlString = "https://opensky-network.org/api/states/all"
            + "?lamin=\(lamin)&lamax=\(lamax)&lomin=\(lomin)&lomax=\(lomax)"

        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                    await MainActor.run {
                        self.errorMessage = "Server returned \(http.statusCode)"
                        self.isLoading = false
                    }
                    return
                }

                let parsed = try parseStates(from: data)
                await MainActor.run {
                    self.aircraft = parsed
                    self.lastUpdated = Date()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Route lookup
    
    func fetchRoute(for aircraft: Aircraft) {
        let id = aircraft.id
        guard routes[id] == nil, !routeLoading.contains(id) else { return }
        
        // Rate limiting: ensure we don't make requests too frequently
        if let lastRequest = lastRouteRequest,
           Date().timeIntervalSince(lastRequest) < minimumRouteRequestInterval {
            if OpenSkyConfig.verboseLogging {
                print("⏱️ Rate limiting: skipping route request for \(id)")
            }
            return
        }
        
        routeLoading.insert(id)
        lastRouteRequest = Date()
        
        // Try AviationStack first if configured
        if OpenSkyConfig.useAlternativeRouteData,
           !aircraft.callsign.trimmingCharacters(in: .whitespaces).isEmpty {
            Task {
                await tryAviationStackRoute(for: aircraft)
            }
            return
        }
        
        // Fall back to OpenSky if enabled
        if OpenSkyConfig.attemptOpenSkyRoutes {
            Task {
                await tryOpenSkyRoute(for: aircraft)
            }
            return
        }
        
        // No route data available - use fallback
        if OpenSkyConfig.verboseLogging {
            print("ℹ️ No route data sources enabled for \(id)")
        }
        Task {
            await createFallbackRoute(for: aircraft)
        }
    }
    
    private func tryAviationStackRoute(for aircraft: Aircraft) async {
        let callsign = aircraft.callsign.trimmingCharacters(in: .whitespaces)
        
        // Check if callsign is empty
        guard !callsign.isEmpty else {
            await createFallbackRoute(for: aircraft)
            return
        }
        
        do {
            if let route = try await aviationStack.fetchRoute(for: callsign, icao24: aircraft.id) {
                await MainActor.run {
                    self.routes[aircraft.id] = route
                    self.routeLoading.remove(aircraft.id)
                }
                return
            }
        } catch {
            if OpenSkyConfig.verboseLogging {
                print("⚠️ AviationStack error: \(error.localizedDescription)")
            }
        }
        
        // AviationStack failed - try OpenSky if enabled
        if OpenSkyConfig.attemptOpenSkyRoutes {
            await tryOpenSkyRoute(for: aircraft)
        } else {
            await createFallbackRoute(for: aircraft)
        }
    }
    
    private func tryOpenSkyRoute(for aircraft: Aircraft) async {
        let id = aircraft.id
        
        // Build URL for flights endpoint
        let baseURL = "https://opensky-network.org/api/flights/aircraft"
        let urlString = "\(baseURL)?icao24=\(id)&begin=\(Int(Date().timeIntervalSince1970) - 86400)&end=\(Int(Date().timeIntervalSince1970))"
        
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                routeLoading.remove(id)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        if OpenSkyConfig.verboseLogging {
            print("🔍 Attempting OpenSky route lookup for \(id)")
        }
        
        // Try without authentication - sometimes this works better
        // Uncomment these lines if you want to try with authentication:
        // if let authHeader = OpenSkyConfig.authorizationHeader {
        //     request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        // }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let http = response as? HTTPURLResponse {
                if OpenSkyConfig.verboseLogging {
                    print("📡 OpenSky HTTP \(http.statusCode) for \(id)")
                }
                
                if http.statusCode == 401 {
                    print("🚫 401: OpenSky authentication failed")
                    await createFallbackRoute(for: aircraft)
                    return
                }
                
                if http.statusCode == 403 {
                    if OpenSkyConfig.verboseLogging {
                        print("🚫 403: OpenSky access forbidden (contributor status required)")
                    }
                    await createFallbackRoute(for: aircraft)
                    return
                }
                
                if http.statusCode == 429 {
                    print("⏱️ 429: OpenSky rate limit exceeded")
                    await createFallbackRoute(for: aircraft)
                    return
                }
                
                if http.statusCode != 200 {
                    if OpenSkyConfig.verboseLogging {
                        print("⚠️ OpenSky unexpected HTTP \(http.statusCode)")
                    }
                    await createFallbackRoute(for: aircraft)
                    return
                }
            }
            
            // Parse the response
            if let flights = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let lastFlight = flights.last,
               let departure = lastFlight["estDepartureAirport"] as? String,
               let arrival = lastFlight["estArrivalAirport"] as? String {
                
                await MainActor.run {
                    let callsign = aircraft.callsign.trimmingCharacters(in: .whitespaces)
                    let route = FlightRoute(
                        icao24: id,
                        departure: departure.isEmpty ? nil : departure,
                        arrival: arrival.isEmpty ? nil : arrival,
                        callsign: callsign.isEmpty ? nil : callsign,
                        isArrivalEstimated: true
                    )
                    self.routes[id] = route
                    self.routeLoading.remove(id)
                    
                    if OpenSkyConfig.verboseLogging {
                        print("✅ OpenSky route: \(departure) → \(arrival)")
                    }
                }
            } else {
                if OpenSkyConfig.verboseLogging {
                    print("ℹ️ No flight data in OpenSky response for \(id)")
                }
                await createFallbackRoute(for: aircraft)
            }
            
        } catch {
            if OpenSkyConfig.verboseLogging {
                print("❌ OpenSky error for \(id): \(error.localizedDescription)")
            }
            await createFallbackRoute(for: aircraft)
        }
    }
    
    private func createFallbackRoute(for aircraft: Aircraft) async {
        await MainActor.run {
            // Try to extract airline info from callsign
            let departure = extractAirportFromCallsign(aircraft.callsign)
            
            // Create route with callsign and any extracted info
            let route = FlightRoute(
                icao24: aircraft.id,
                departure: departure,
                arrival: nil, // We don't have arrival data without the API
                callsign: aircraft.callsign.trimmingCharacters(in: .whitespaces).isEmpty ? nil : aircraft.callsign,
                isArrivalEstimated: false
            )
            self.routes[aircraft.id] = route
            self.routeLoading.remove(aircraft.id)
            
            if departure != nil {
                print("ℹ️ Created route with airline code: \(aircraft.callsign)")
            }
        }
    }
    
    private func extractAirportFromCallsign(_ callsign: String) -> String? {
        // This is a simple heuristic - in production you'd want a proper airline database
        // Common airline codes around Sydney:
        // QFA/QF = Qantas, VOZ/VA = Virgin Australia, JST/JQ = Jetstar, etc.
        let cs = callsign.trimmingCharacters(in: .whitespaces)
        guard cs.count >= 3 else {
            return nil
        }
        
        // Extract airline code (usually first 3 characters)
        let airlineCode = String(cs.prefix(3))
        return airlineCode // You could map this to full airline names if desired
    }

    func isLoadingRoute(_ icao24: String) -> Bool { routeLoading.contains(icao24) }

    private func parseStates(from data: Data) throws -> [Aircraft] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let states = json["states"] as? [[Any]]
        else { return [] }

        return states.compactMap { Aircraft(from: $0) }
                     .filter { !$0.onGround || $0.velocity ?? 0 > 5 }
    }
}
