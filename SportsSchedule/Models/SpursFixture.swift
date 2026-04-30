import Foundation

enum FixtureResult {
    case win, draw, loss, upcoming

    var label: String {
        switch self {
        case .win: return "W"
        case .draw: return "D"
        case .loss: return "L"
        case .upcoming: return ""
        }
    }

    var color: String {
        switch self {
        case .win: return "ResultGreen"
        case .draw: return "ResultAmber"
        case .loss: return "ResultRed"
        case .upcoming: return "AccentBlue"
        }
    }
}

struct SpursFixture: Identifiable {
    let id = UUID()
    let date: Date
    let opponent: String
    let competition: String
    let isHome: Bool
    let spursScore: Int?
    let opponentScore: Int?
    let venue: String

    var isUpcoming: Bool { spursScore == nil }

    var result: FixtureResult {
        guard let s = spursScore, let o = opponentScore else { return .upcoming }
        if s > o { return .win }
        if s < o { return .loss }
        return .draw
    }

    var scoreText: String {
        guard let s = spursScore, let o = opponentScore else { return "vs" }
        return isHome ? "\(s) - \(o)" : "\(o) - \(s)"
    }

    var homeTeam: String { isHome ? "Tottenham" : opponent }
    var awayTeam: String { isHome ? opponent : "Tottenham" }
}

extension SpursFixture {
    static let sampleData: [SpursFixture] = {
        let cal = Calendar.current
        func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
            var c = DateComponents()
            c.year = year; c.month = month; c.day = day; c.hour = 15
            return Calendar.current.date(from: c)!
        }

        return [
            // Upcoming
            SpursFixture(date: date(2026, 5, 3),  opponent: "Liverpool",        competition: "Premier League", isHome: true,  spursScore: nil, opponentScore: nil, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 5, 10), opponent: "Newcastle United",  competition: "Premier League", isHome: false, spursScore: nil, opponentScore: nil, venue: "St. James' Park"),
            SpursFixture(date: date(2026, 5, 17), opponent: "Everton",           competition: "Premier League", isHome: true,  spursScore: nil, opponentScore: nil, venue: "Tottenham Hotspur Stadium"),

            // Past results (most recent first)
            SpursFixture(date: date(2026, 4, 26), opponent: "Chelsea",           competition: "Premier League", isHome: true,  spursScore: 2, opponentScore: 1, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 4, 19), opponent: "Manchester City",   competition: "Premier League", isHome: false, spursScore: 1, opponentScore: 1, venue: "Etihad Stadium"),
            SpursFixture(date: date(2026, 4, 12), opponent: "Brentford",         competition: "Premier League", isHome: true,  spursScore: 3, opponentScore: 0, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 4, 5),  opponent: "Wolverhampton",     competition: "Premier League", isHome: false, spursScore: 2, opponentScore: 0, venue: "Molineux Stadium"),
            SpursFixture(date: date(2026, 3, 29), opponent: "Arsenal",           competition: "Premier League", isHome: true,  spursScore: 1, opponentScore: 2, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 3, 22), opponent: "Aston Villa",       competition: "Premier League", isHome: false, spursScore: 2, opponentScore: 2, venue: "Villa Park"),
            SpursFixture(date: date(2026, 3, 15), opponent: "Brighton",          competition: "Premier League", isHome: true,  spursScore: 3, opponentScore: 1, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 3, 8),  opponent: "Manchester United", competition: "Premier League", isHome: false, spursScore: 0, opponentScore: 1, venue: "Old Trafford"),
            SpursFixture(date: date(2026, 3, 1),  opponent: "West Ham United",   competition: "Premier League", isHome: true,  spursScore: 4, opponentScore: 1, venue: "Tottenham Hotspur Stadium"),
            SpursFixture(date: date(2026, 2, 22), opponent: "Nottm Forest",      competition: "Premier League", isHome: false, spursScore: 1, opponentScore: 1, venue: "City Ground"),
            SpursFixture(date: date(2026, 2, 15), opponent: "Leicester City",    competition: "Premier League", isHome: true,  spursScore: 2, opponentScore: 0, venue: "Tottenham Hotspur Stadium"),
        ]
    }()
}
