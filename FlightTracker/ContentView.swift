import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var service = OpenSkyService()
    @State private var selectedAircraft: Aircraft?
    @State private var showFlightList = false
    @State private var mapType: MKMapType = .hybridFlyover
    @State private var showError = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-screen radar map
            RadarMapView(
                aircraft: service.aircraft,
                selectedAircraft: $selectedAircraft,
                mapType: mapType
            )
            .ignoresSafeArea()
            .onTapGesture {
                // Tap on empty area → deselect
                if selectedAircraft != nil {
                    withAnimation(.spring(response: 0.3)) {
                        selectedAircraft = nil
                    }
                }
            }

            // Top stats bar
            VStack {
                StatsBarView(
                    count: service.aircraft.count,
                    lastUpdated: service.lastUpdated,
                    isLoading: service.isLoading,
                    onRefresh: service.fetchAircraft
                )
                Spacer()
            }

            // Right-side controls
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    MapControlButton(icon: mapType == .hybridFlyover ? "map" : "globe.americas.fill") {
                        mapType = mapType == .hybridFlyover ? .standard : .hybridFlyover
                    }
                    MapControlButton(icon: "list.bullet") {
                        showFlightList = true
                    }
                    .overlay(
                        Text("\(service.aircraft.count)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 12, y: -12),
                        alignment: .topTrailing
                    )
                }
                .padding(.trailing, 16)
                .padding(.bottom, selectedAircraft != nil ? 300 : 100)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Bottom: aircraft detail or flight count pill
            if let ac = selectedAircraft {
                AircraftDetailView(aircraft: ac) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedAircraft = nil
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            } else {
                // Flight count pill at bottom
                Button {
                    showFlightList = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "airplane")
                            .font(.caption)
                        Text(service.aircraft.isEmpty
                            ? "Scanning…"
                            : "View \(service.aircraft.count) flights near Sydney"
                        )
                        .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(20)
                }
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.35), value: selectedAircraft?.id)
        .sheet(isPresented: $showFlightList) {
            FlightListView(
                aircraft: service.aircraft,
                selectedAircraft: $selectedAircraft,
                isPresented: $showFlightList
            )
        }
        .alert("Network Error", isPresented: $showError) {
            Button("Retry") { service.fetchAircraft() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(service.errorMessage ?? "Unable to fetch flight data.")
        }
        .onChange(of: service.errorMessage) { _, error in
            showError = error != nil
        }
        .onAppear { service.startTracking() }
        .onDisappear { service.stopTracking() }
    }
}

private struct MapControlButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.regularMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
    }
}

#Preview {
    ContentView()
}
