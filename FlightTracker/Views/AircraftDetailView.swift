import SwiftUI

struct AircraftDetailView: View {
    let aircraft: Aircraft
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 4)

            // Header
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(aircraft.countryFlag)
                            .font(.title2)
                        Text(aircraft.displayCallsign)
                            .font(.system(.title2, design: .monospaced, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text(aircraft.originCountry)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("ICAO: \(aircraft.id.uppercased())")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Spacer()
                // Status badge
                VStack(spacing: 4) {
                    Text(aircraft.onGround ? "ON GROUND" : "IN FLIGHT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(aircraft.onGround ? Color.gray : Color.green)
                        .cornerRadius(6)

                    if let squawk = aircraft.squawk, !squawk.isEmpty {
                        Text("SQK \(squawk)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 1) {
                StatCell(
                    icon: "arrow.up.to.line",
                    label: "Altitude",
                    value: aircraft.altitudeFeet.map { "\($0.formatted())" } ?? "—",
                    unit: aircraft.altitudeFeet != nil ? "ft" : "",
                    color: altColor
                )
                StatCell(
                    icon: "speedometer",
                    label: "Airspeed",
                    value: aircraft.speedKnots.map { "\($0)" } ?? "—",
                    unit: aircraft.speedKnots != nil ? "kt" : "",
                    color: .cyan
                )
                StatCell(
                    icon: "location.north.fill",
                    label: "Heading",
                    value: aircraft.heading.map { "\(Int($0))°" } ?? "—",
                    unit: aircraft.headingCardinal,
                    color: .orange
                )
                StatCell(
                    icon: "arrow.up.arrow.down",
                    label: "Vert. Speed",
                    value: aircraft.verticalRateFpm.map { "\(aircraft.climbDescendIcon)\(abs($0).formatted())" } ?? "—",
                    unit: aircraft.verticalRateFpm != nil ? "fpm" : "",
                    color: vspeedColor
                )
                StatCell(
                    icon: "mappin.circle",
                    label: "Latitude",
                    value: String(format: "%.4f°", aircraft.latitude),
                    unit: aircraft.latitude >= 0 ? "N" : "S",
                    color: .purple
                )
                StatCell(
                    icon: "mappin.circle.fill",
                    label: "Longitude",
                    value: String(format: "%.4f°", aircraft.longitude),
                    unit: aircraft.longitude >= 0 ? "E" : "W",
                    color: .purple
                )
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Last contact
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Last contact: \(aircraft.lastContact, style: .relative) ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.25), radius: 16, y: -4)
        )
    }

    private var altColor: Color {
        switch aircraft.altitudeCategory {
        case .ground:  return .gray
        case .low:     return .green
        case .medium:  return .yellow
        case .high:    return Color(red: 0.4, green: 0.8, blue: 1.0)
        }
    }

    private var vspeedColor: Color {
        guard let vr = aircraft.verticalRate else { return .secondary }
        if vr > 1  { return .green }
        if vr < -1 { return .red }
        return .secondary
    }
}

private struct StatCell: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(.subheadline, design: .monospaced, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    AircraftDetailView(aircraft: Aircraft(
        id: "7c6b12",
        callsign: "QFA1",
        originCountry: "Australia",
        longitude: 151.177,
        latitude: -33.946,
        baroAltitude: 10972,
        geoAltitude: 11200,
        onGround: false,
        velocity: 245,
        heading: 135,
        verticalRate: -2.5,
        squawk: "2541",
        lastContact: Date()
    ), onDismiss: {})
}
