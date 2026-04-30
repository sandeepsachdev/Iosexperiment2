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
        routeLoading.insert(id)

        let end   = Int(Date().timeIntervalSince1970)
        let begin = end - 86400   // look back 24 hours

        guard let url = URL(string: "https://opensky-network.org/api/flights/aircraft?icao24=\(id)&begin=\(begin)&end=\(end)") else {
            routeLoading.remove(id)
            return
        }

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                var route: FlightRoute? = nil
                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    route = FlightRoute.parse(from: data, icao24: id)
                }
                await MainActor.run {
                    // Store even if nil so we don't retry endlessly for this session
                    self.routes[id] = route ?? FlightRoute(icao24: id, departure: nil, arrival: nil, callsign: nil, isArrivalEstimated: false)
                    self.routeLoading.remove(id)
                }
            } catch {
                await MainActor.run { self.routeLoading.remove(id) }
            }
        }
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
