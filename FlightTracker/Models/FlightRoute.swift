import Foundation

struct FlightRoute {
    let icao24: String
    let departure: String?   // ICAO code e.g. "YSSY"
    let arrival: String?     // ICAO code (estimated)
    let callsign: String?
    let isArrivalEstimated: Bool

    var departureAirport: Airport? { departure.flatMap { AirportDatabase.lookup($0) } }
    var arrivalAirport: Airport?   { arrival.flatMap   { AirportDatabase.lookup($0) } }
}

extension FlightRoute {
    // Parse from OpenSky /flights/aircraft endpoint
    // Response is an array of flight records; we take the most recent
    static func parse(from data: Data, icao24: String) -> FlightRoute? {
        guard let flights = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let recent = flights.last
        else { return nil }

        let dep  = recent["estDepartureAirport"] as? String
        let arr  = recent["estArrivalAirport"]   as? String
        let cs   = (recent["callsign"] as? String).map { $0.trimmingCharacters(in: .whitespaces) }
        // arrival is flagged estimated when the plane is still airborne
        let arrEstimated = arr == nil || (recent["estArrivalAirportCandidatesCount"] as? Int ?? 0) > 1

        return FlightRoute(icao24: icao24, departure: dep, arrival: arr, callsign: cs, isArrivalEstimated: arrEstimated)
    }
}
