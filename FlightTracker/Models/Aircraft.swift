import Foundation
import CoreLocation
import UIKit

struct Aircraft: Identifiable, Equatable {
    let id: String          // icao24
    let callsign: String
    let originCountry: String
    let longitude: Double
    let latitude: Double
    let baroAltitude: Double?   // meters
    let geoAltitude: Double?    // meters
    let onGround: Bool
    let velocity: Double?       // m/s
    let heading: Double?        // degrees true
    let verticalRate: Double?   // m/s
    let squawk: String?
    let lastContact: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var displayCallsign: String {
        let trimmed = callsign.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? id.uppercased() : trimmed
    }

    // Unit conversions
    var altitudeFeet: Int? { baroAltitude.map { Int($0 * 3.28084) } }
    var speedKnots: Int?   { velocity.map { Int($0 * 1.94384) } }
    var verticalRateFpm: Int? { verticalRate.map { Int($0 * 196.85) } }

    var headingCardinal: String {
        guard let h = heading else { return "—" }
        let dirs = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
                    "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let idx = Int((h + 11.25) / 22.5) % 16
        return dirs[idx]
    }

    var altitudeCategory: AltitudeCategory {
        guard !onGround, let alt = baroAltitude else { return .ground }
        if alt < 1500  { return .low }
        if alt < 8000  { return .medium }
        return .high
    }

    var altitudeCategoryColor: UIColor {
        switch altitudeCategory {
        case .ground: return .systemGray
        case .low:    return .systemGreen
        case .medium: return .systemYellow
        case .high:   return UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
        }
    }

    var climbDescendIcon: String {
        guard let vr = verticalRate else { return "" }
        if vr > 1  { return "↑" }
        if vr < -1 { return "↓" }
        return "→"
    }

    var countryFlag: String { Aircraft.flagEmoji(for: originCountry) }

    enum AltitudeCategory { case ground, low, medium, high }

    static func == (lhs: Aircraft, rhs: Aircraft) -> Bool { lhs.id == rhs.id }
}

// MARK: - JSON Parsing
extension Aircraft {
    init?(from stateVector: [Any]) {
        guard stateVector.count >= 17,
              let icao = stateVector.string(0),
              let lon  = stateVector.double(5),
              let lat  = stateVector.double(6)
        else { return nil }

        self.id            = icao
        self.callsign      = stateVector.string(1) ?? ""
        self.originCountry = stateVector.string(2) ?? ""
        self.longitude     = lon
        self.latitude      = lat
        self.baroAltitude  = stateVector.double(7)
        self.geoAltitude   = stateVector.double(13)
        self.onGround      = stateVector.bool(8) ?? false
        self.velocity      = stateVector.double(9)
        self.heading       = stateVector.double(10)
        self.verticalRate  = stateVector.double(11)
        self.squawk        = stateVector.string(14)

        let ts = stateVector.int(4) ?? 0
        self.lastContact = Date(timeIntervalSince1970: TimeInterval(ts))
    }
}

// MARK: - Country flags
extension Aircraft {
    static func flagEmoji(for country: String) -> String {
        let map: [String: String] = [
            "Australia": "🇦🇺", "United States": "🇺🇸", "United Kingdom": "🇬🇧",
            "Singapore": "🇸🇬", "New Zealand": "🇳🇿", "Japan": "🇯🇵",
            "China": "🇨🇳", "United Arab Emirates": "🇦🇪", "Qatar": "🇶🇦",
            "India": "🇮🇳", "South Korea": "🇰🇷", "Malaysia": "🇲🇾",
            "Indonesia": "🇮🇩", "Thailand": "🇹🇭", "Philippines": "🇵🇭",
            "Hong Kong": "🇭🇰", "Taiwan": "🇹🇼", "Vietnam": "🇻🇳",
            "Germany": "🇩🇪", "France": "🇫🇷", "Netherlands": "🇳🇱",
            "Canada": "🇨🇦", "Fiji": "🇫🇯", "Papua New Guinea": "🇵🇬",
            "Saudi Arabia": "🇸🇦", "South Africa": "🇿🇦", "Kenya": "🇰🇪",
        ]
        return map[country] ?? "🌐"
    }
}

// MARK: - Array helpers for JSON state vectors
private extension Array where Element == Any {
    func string(_ i: Int) -> String? {
        guard i < count, !(self[i] is NSNull) else { return nil }
        return self[i] as? String
    }
    func double(_ i: Int) -> Double? {
        guard i < count, !(self[i] is NSNull) else { return nil }
        if let d = self[i] as? Double { return d }
        if let n = self[i] as? Int    { return Double(n) }
        return nil
    }
    func bool(_ i: Int) -> Bool? {
        guard i < count, !(self[i] is NSNull) else { return nil }
        return self[i] as? Bool
    }
    func int(_ i: Int) -> Int? {
        guard i < count, !(self[i] is NSNull) else { return nil }
        if let n = self[i] as? Int    { return n }
        if let d = self[i] as? Double { return Int(d) }
        return nil
    }
}
