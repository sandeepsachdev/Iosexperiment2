import Foundation
import Combine

@MainActor
final class OpenSkyService: ObservableObject {
    @Published var aircraft: [Aircraft] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?

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

    private func parseStates(from data: Data) throws -> [Aircraft] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let states = json["states"] as? [[Any]]
        else { return [] }

        return states.compactMap { Aircraft(from: $0) }
                     .filter { !$0.onGround || $0.velocity ?? 0 > 5 }
    }
}
