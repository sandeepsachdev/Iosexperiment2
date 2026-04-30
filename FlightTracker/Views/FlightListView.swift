import SwiftUI

struct FlightListView: View {
    let aircraft: [Aircraft]
    let routes: [String: FlightRoute]
    @Binding var selectedAircraft: Aircraft?
    @Binding var isPresented: Bool

    @State private var searchText = ""
    @State private var sortMode: SortMode = .altitude

    enum SortMode: String, CaseIterable {
        case altitude = "Altitude"
        case speed = "Speed"
        case callsign = "Callsign"
    }

    private var filtered: [Aircraft] {
        let base = searchText.isEmpty ? aircraft : aircraft.filter {
            $0.displayCallsign.localizedCaseInsensitiveContains(searchText) ||
            $0.originCountry.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            (routes[$0.id]?.airlineName?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
        switch sortMode {
        case .altitude: return base.sorted { ($0.baroAltitude ?? -1) > ($1.baroAltitude ?? -1) }
        case .speed:    return base.sorted { ($0.velocity ?? -1) > ($1.velocity ?? -1) }
        case .callsign: return base.sorted { $0.displayCallsign < $1.displayCallsign }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sort picker
                Picker("Sort", selection: $sortMode) {
                    ForEach(SortMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Divider()

                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "airplane.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(aircraft.isEmpty ? "No aircraft detected" : "No results for \"\(searchText)\"")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List(filtered) { ac in
                        FlightRow(aircraft: ac, route: routes[ac.id])
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedAircraft = ac
                                isPresented = false
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Search callsign, airline, country, ICAO…")
            .navigationTitle("\(aircraft.count) Aircraft Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}

private struct FlightRow: View {
    let aircraft: Aircraft
    let route: FlightRoute?

    var altColor: Color {
        switch aircraft.altitudeCategory {
        case .ground:  return .gray
        case .low:     return .green
        case .medium:  return .yellow
        case .high:    return Color(red: 0.4, green: 0.8, blue: 1.0)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Plane icon
            ZStack {
                Circle()
                    .fill(altColor.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: "airplane")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(altColor)
                    .rotationEffect(.degrees((aircraft.heading ?? 0) - 90))
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(aircraft.displayCallsign)
                        .font(.system(.subheadline, design: .monospaced, weight: .bold))
                    Text(aircraft.countryFlag)
                }
                
                // Show airline if available, otherwise show country
                if let airline = route?.airlineName {
                    Text(airline)
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Text(aircraft.originCountry)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Show route if available
                if let dep = route?.departure, let arr = route?.arrival {
                    HStack(spacing: 4) {
                        Text(dep)
                            .font(.system(size: 10, design: .monospaced))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8))
                        Text(arr)
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Stats
            VStack(alignment: .trailing, spacing: 3) {
                if let alt = aircraft.altitudeFeet {
                    Label("\(alt.formatted()) ft", systemImage: "arrow.up.to.line")
                        .font(.caption)
                        .foregroundColor(altColor)
                }
                if let spd = aircraft.speedKnots {
                    Label("\(spd) kt", systemImage: "speedometer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(aircraft.onGround ? "Ground" : "\(aircraft.headingCardinal)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .labelStyle(.titleAndIcon)
        }
    }
}
