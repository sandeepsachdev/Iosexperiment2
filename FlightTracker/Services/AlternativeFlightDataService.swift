import Foundation

/// Alternative flight data services that provide route information
/// These are more reliable than OpenSky's restricted /flights endpoint

// MARK: - AviationStack Implementation (Recommended)
/// Free tier: 500 requests/month
/// Sign up at: https://aviationstack.com/

struct AviationStackService {
    
    func fetchRoute(for callsign: String, icao24: String) async throws -> FlightRoute? {
        guard let apiKey = OpenSkyConfig.aviationStackAPIKey, !apiKey.isEmpty else {
            if OpenSkyConfig.verboseLogging {
                print("⚠️ AviationStack API key not configured")
                print("   Sign up at https://aviationstack.com/ and add to environment variables")
            }
            return nil
        }
        
        // Clean up callsign - remove whitespace
        let cleanCallsign = callsign.trimmingCharacters(in: .whitespaces)
        
        // Try both ICAO and IATA callsign formats
        let urlString = "https://api.aviationstack.com/v1/flights"
            + "?access_key=\(apiKey)"
            + "&flight_icao=\(cleanCallsign)"
            + "&limit=1"
        
        guard let url = URL(string: urlString) else { 
            print("❌ Invalid AviationStack URL")
            return nil 
        }
        
        if OpenSkyConfig.verboseLogging {
            print("✈️ Fetching AviationStack route for \(cleanCallsign)")
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response from AviationStack")
            return nil
        }
        
        if OpenSkyConfig.verboseLogging {
            print("📡 AviationStack HTTP \(http.statusCode)")
        }
        
        if http.statusCode != 200 {
            if let errorStr = String(data: data, encoding: .utf8) {
                print("⚠️ AviationStack error: \(errorStr.prefix(200))")
            }
            return nil
        }
        
        return parseAviationStackResponse(data, icao24: icao24, callsign: callsign)
    }
    
    private func parseAviationStackResponse(_ data: Data, icao24: String, callsign: String) -> FlightRoute? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let flights = json["data"] as? [[String: Any]],
              !flights.isEmpty
        else { 
            if OpenSkyConfig.verboseLogging {
                print("ℹ️ No flights found in AviationStack response")
            }
            return nil 
        }
        
        let flight = flights[0]
        
        // Parse departure
        let departure = flight["departure"] as? [String: Any]
        let depIcao = departure?["icao"] as? String
        let depIata = departure?["iata"] as? String
        
        // Parse arrival
        let arrival = flight["arrival"] as? [String: Any]
        let arrIcao = arrival?["icao"] as? String
        let arrIata = arrival?["iata"] as? String
        
        // Parse flight info
        let flightInfo = flight["flight"] as? [String: Any]
        let flightCallsign = flightInfo?["icao"] as? String ?? flightInfo?["iata"] as? String
        
        if OpenSkyConfig.verboseLogging {
            print("✅ AviationStack route: \(depIcao ?? depIata ?? "???") → \(arrIcao ?? arrIata ?? "???")")
        }
        
        return FlightRoute(
            icao24: icao24,
            departure: depIcao ?? depIata,
            arrival: arrIcao ?? arrIata,
            callsign: flightCallsign ?? callsign,
            isArrivalEstimated: false
        )
    }
}

// MARK: - FlightAware API (Commercial)
/// More expensive but very reliable
/// https://www.flightaware.com/commercial/aeroapi/

// MARK: - Alternative: Parse Callsign for Airline Info
extension String {
    /// Extracts airline code from callsign (e.g., "QFA123" -> "QFA")
    var airlineCode: String? {
        let pattern = "^([A-Z]{3})[0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: self, range: NSRange(location: 0, length: count))
        else { return nil }
        
        return (self as NSString).substring(with: match.range(at: 1))
    }
    
    /// Common airline codes for better UX
    var airlineName: String? {
        let airlines: [String: String] = [
            "QFA": "Qantas",
            "QAN": "Qantas",
            "VOZ": "Virgin Australia",
            "JST": "Jetstar",
            "UAL": "United Airlines",
            "DAL": "Delta",
            "AAL": "American Airlines",
            "SWA": "Southwest",
            "UAE": "Emirates",
            "SIA": "Singapore Airlines",
            "CPA": "Cathay Pacific",
            // Add more as needed
        ]
        return airlineCode.flatMap { airlines[$0] }
    }
}
