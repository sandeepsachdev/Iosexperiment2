import Foundation

struct FlightRoute {
    let icao24: String
    let departure: String?   // ICAO code e.g. "YSSY"
    let arrival: String?     // ICAO code (estimated)
    let callsign: String?
    let isArrivalEstimated: Bool

    var departureAirport: Airport? { departure.flatMap { AirportDatabase.lookup($0) } }
    var arrivalAirport: Airport?   { arrival.flatMap   { AirportDatabase.lookup($0) } }
    
    /// Extract airline name from callsign (e.g., "QFA123" -> "Qantas")
    var airlineName: String? {
        guard let cs = callsign?.trimmingCharacters(in: .whitespaces),
              cs.count >= 3 else { return nil }
        
        let airlineCode = String(cs.prefix(3))
        return FlightRoute.knownAirlines[airlineCode]
    }
    
    /// Common airline ICAO codes
    private static let knownAirlines: [String: String] = [
        "QFA": "Qantas", "QAN": "Qantas",
        "VOZ": "Virgin Australia", "VAU": "Virgin Australia",
        "JST": "Jetstar", "JTE": "Jetstar",
        "UAL": "United Airlines",
        "DAL": "Delta Air Lines",
        "AAL": "American Airlines",
        "SWA": "Southwest Airlines",
        "UAE": "Emirates",
        "SIA": "Singapore Airlines",
        "CPA": "Cathay Pacific",
        "ANZ": "Air New Zealand",
        "QTR": "Qatar Airways",
        "BAW": "British Airways",
        "DLH": "Lufthansa",
        "AFR": "Air France",
        "KLM": "KLM Royal Dutch Airlines",
        "ANA": "All Nippon Airways",
        "JAL": "Japan Airlines",
        "THA": "Thai Airways",
    ]
}

extension FlightRoute {
    // Parse from OpenSky /flights/aircraft endpoint
    // Note: This endpoint is heavily restricted and often returns 403
    static func parse(from data: Data, icao24: String) -> FlightRoute? {
        guard let flights = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              !flights.isEmpty,
              let recent = flights.last
        else { 
            return nil 
        }
        
        let dep  = recent["estDepartureAirport"] as? String ?? recent["departureAirport"] as? String
        let arr  = recent["estArrivalAirport"] as? String ?? recent["arrivalAirport"] as? String
        let cs   = (recent["callsign"] as? String)?.trimmingCharacters(in: .whitespaces)
        
        // Only create route if we have actual data
        guard dep != nil || arr != nil else { return nil }
        
        let arrEstimated = arr == nil || (recent["estArrivalAirportCandidatesCount"] as? Int ?? 0) > 1

        return FlightRoute(icao24: icao24, departure: dep, arrival: arr, callsign: cs, isArrivalEstimated: arrEstimated)
    }
}
