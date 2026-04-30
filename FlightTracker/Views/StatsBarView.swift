import SwiftUI

struct StatsBarView: View {
    let count: Int
    let lastUpdated: Date?
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            // Pulse dot
            ZStack {
                Circle()
                    .fill(count > 0 ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                if isLoading {
                    Circle()
                        .stroke(Color.green.opacity(0.4), lineWidth: 2)
                        .frame(width: 14, height: 14)
                        .scaleEffect(isLoading ? 1.5 : 1)
                        .opacity(isLoading ? 0 : 1)
                        .animation(.easeOut(duration: 1).repeatForever(), value: isLoading)
                }
            }

            Text(isLoading ? "Updating…" : "\(count) aircraft")
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .foregroundColor(.white)

            if let updated = lastUpdated {
                Text("·")
                    .foregroundColor(.white.opacity(0.5))
                Text(updated, style: .timer)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isLoading ? 360 : 0))
                    .animation(isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoading)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial.opacity(0.9))
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
