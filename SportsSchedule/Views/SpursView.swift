import SwiftUI

struct SpursView: View {
    private let upcoming = SpursFixture.sampleData.filter { $0.isUpcoming }
    private let results  = SpursFixture.sampleData.filter { !$0.isUpcoming }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SpursHeaderView()

                    SectionHeaderView(title: "Upcoming Fixtures", icon: "calendar")
                    ForEach(upcoming) { fixture in
                        UpcomingFixtureRow(fixture: fixture)
                        Divider().padding(.leading, 16)
                    }

                    SectionHeaderView(title: "Recent Results", icon: "clock.arrow.circlepath")
                    ForEach(results) { fixture in
                        ResultFixtureRow(fixture: fixture)
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tottenham Hotspur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("⚪")
                        .font(.title2)
                }
            }
        }
    }
}

private struct SpursHeaderView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.22, blue: 0.42), Color(red: 0.04, green: 0.14, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Text("⚪")
                    .font(.system(size: 56))
                Text("Tottenham Hotspur")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                Text("Premier League · 2025/26")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(.vertical, 28)
        }
    }
}

private struct SectionHeaderView: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.07, green: 0.22, blue: 0.42))
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

private struct UpcomingFixtureRow: View {
    let fixture: SpursFixture

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fixture.competition)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(4)
                    HStack(spacing: 8) {
                        Text(fixture.homeTeam)
                            .font(.system(.subheadline, design: .rounded)).bold()
                            .foregroundColor(fixture.isHome ? Color(red: 0.07, green: 0.22, blue: 0.42) : .primary)
                        Text("vs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(fixture.awayTeam)
                            .font(.system(.subheadline, design: .rounded)).bold()
                            .foregroundColor(!fixture.isHome ? Color(red: 0.07, green: 0.22, blue: 0.42) : .primary)
                    }
                    Text(fixture.venue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(fixture.date, style: .date)
                        .font(.caption).bold()
                        .foregroundColor(Color(red: 0.07, green: 0.22, blue: 0.42))
                    Text(fixture.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(fixture.isHome ? "HOME" : "AWAY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(fixture.isHome ? .white : Color(red: 0.07, green: 0.22, blue: 0.42))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(fixture.isHome ? Color(red: 0.07, green: 0.22, blue: 0.42) : Color(.secondarySystemFill))
                        .cornerRadius(4)
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
    }
}

private struct ResultFixtureRow: View {
    let fixture: SpursFixture

    var resultColor: Color {
        switch fixture.result {
        case .win:  return Color(red: 0.13, green: 0.63, blue: 0.34)
        case .draw: return Color(red: 0.80, green: 0.55, blue: 0.08)
        case .loss: return Color(red: 0.82, green: 0.16, blue: 0.18)
        case .upcoming: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Result badge
            Text(fixture.result.label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(resultColor)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(fixture.competition)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 6) {
                    Text(fixture.homeTeam)
                        .font(.system(.subheadline, design: .rounded)).bold()
                        .foregroundColor(fixture.isHome ? Color(red: 0.07, green: 0.22, blue: 0.42) : .primary)
                    Text(fixture.scoreText)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy))
                        .foregroundColor(.primary)
                    Text(fixture.awayTeam)
                        .font(.system(.subheadline, design: .rounded)).bold()
                        .foregroundColor(!fixture.isHome ? Color(red: 0.07, green: 0.22, blue: 0.42) : .primary)
                }
            }
            Spacer()
            Text(fixture.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

#Preview {
    SpursView()
}
