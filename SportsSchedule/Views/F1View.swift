import SwiftUI

struct F1View: View {
    @State private var showingPast = false

    private let upcoming = F1Race.upcoming
    private let past = F1Race.past

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    F1HeaderView()

                    // Season progress
                    SeasonProgressView(total: F1Race.season2026.count, completed: past.count)

                    // Upcoming races
                    F1SectionHeader(title: "Upcoming Races", icon: "flag.checkered")
                    ForEach(upcoming) { race in
                        UpcomingRaceRow(race: race)
                        Divider().padding(.leading, 16)
                    }

                    // Past races toggle
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingPast.toggle()
                        }
                    } label: {
                        HStack {
                            F1SectionHeader(title: "Past Races", icon: "clock.arrow.circlepath")
                            Spacer()
                            Image(systemName: showingPast ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.trailing, 16)
                        }
                    }
                    .buttonStyle(.plain)

                    if showingPast {
                        ForEach(past) { race in
                            PastRaceRow(race: race)
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Formula 1 · 2026")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct F1HeaderView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.88, green: 0.08, blue: 0.08), Color(red: 0.55, green: 0.04, blue: 0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Text("🏎️")
                    .font(.system(size: 52))
                Text("Formula 1")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                Text("2026 Season Schedule")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 28)
        }
    }
}

private struct SeasonProgressView: View {
    let total: Int
    let completed: Int

    var progress: Double { Double(completed) / Double(total) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Season Progress")
                    .font(.subheadline).bold()
                Spacer()
                Text("\(completed) / \(total) races")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemFill))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.88, green: 0.08, blue: 0.08))
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

private struct F1SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.88, green: 0.08, blue: 0.08))
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

private struct UpcomingRaceRow: View {
    let race: F1Race

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMM"; return f
    }()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d"; return f
    }()

    var body: some View {
        HStack(spacing: 16) {
            // Date block
            VStack(spacing: 2) {
                Text(Self.monthFormatter.string(from: race.raceDate).uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(red: 0.88, green: 0.08, blue: 0.08))
                Text(Self.dayFormatter.string(from: race.raceDate))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(width: 44)

            // Flag + info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(race.flag)
                        .font(.title3)
                    Text("Round \(race.round)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(4)
                }
                Text(race.name)
                    .font(.system(.subheadline, design: .rounded)).bold()
                Text("\(race.city), \(race.country)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Qualifying: \(race.qualifyingDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

private struct PastRaceRow: View {
    let race: F1Race

    var body: some View {
        HStack(spacing: 16) {
            Text(race.flag)
                .font(.title2)
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Rd \(race.round)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(race.name)
                        .font(.system(.subheadline, design: .rounded)).bold()
                }
                if let winner = race.winner, let team = race.winnerTeam {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(winner)
                            .font(.caption).bold()
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(team)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if let fl = race.fastestLap {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                        Text("Fastest: \(fl)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            Text(race.raceDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

#Preview {
    F1View()
}
