import Foundation

struct F1Race: Identifiable {
    let id = UUID()
    let round: Int
    let name: String
    let circuit: String
    let country: String
    let city: String
    let raceDate: Date
    let qualifyingDate: Date
    let flag: String
    let winner: String?
    let winnerTeam: String?
    let fastestLap: String?

    var isUpcoming: Bool { winner == nil }
    var isPast: Bool { !isUpcoming }
}

extension F1Race {
    static let season2026: [F1Race] = {
        func date(_ month: Int, _ day: Int, _ hour: Int = 14) -> Date {
            var c = DateComponents()
            c.year = 2026; c.month = month; c.day = day; c.hour = hour
            return Calendar.current.date(from: c)!
        }

        return [
            // Past races
            F1Race(round: 1,  name: "Bahrain Grand Prix",          circuit: "Bahrain International Circuit",     country: "Bahrain",      city: "Sakhir",       raceDate: date(3, 1),  qualifyingDate: date(2, 28), flag: "🇧🇭", winner: "Max Verstappen",   winnerTeam: "Red Bull Racing",  fastestLap: "Lando Norris"),
            F1Race(round: 2,  name: "Saudi Arabian Grand Prix",    circuit: "Jeddah Corniche Circuit",           country: "Saudi Arabia", city: "Jeddah",       raceDate: date(3, 8),  qualifyingDate: date(3, 7),  flag: "🇸🇦", winner: "Lando Norris",     winnerTeam: "McLaren",          fastestLap: "Max Verstappen"),
            F1Race(round: 3,  name: "Australian Grand Prix",       circuit: "Albert Park Circuit",               country: "Australia",    city: "Melbourne",    raceDate: date(3, 22), qualifyingDate: date(3, 21), flag: "🇦🇺", winner: "Charles Leclerc",  winnerTeam: "Ferrari",          fastestLap: "Carlos Sainz"),
            F1Race(round: 4,  name: "Japanese Grand Prix",         circuit: "Suzuka International Racing Course",country: "Japan",        city: "Suzuka",       raceDate: date(4, 5),  qualifyingDate: date(4, 4),  flag: "🇯🇵", winner: "Max Verstappen",   winnerTeam: "Red Bull Racing",  fastestLap: "Max Verstappen"),
            F1Race(round: 5,  name: "Chinese Grand Prix",          circuit: "Shanghai International Circuit",    country: "China",        city: "Shanghai",     raceDate: date(4, 19), qualifyingDate: date(4, 18), flag: "🇨🇳", winner: "Lando Norris",     winnerTeam: "McLaren",          fastestLap: "Oscar Piastri"),

            // Upcoming races
            F1Race(round: 6,  name: "Miami Grand Prix",            circuit: "Miami International Autodrome",     country: "USA",          city: "Miami",        raceDate: date(5, 10), qualifyingDate: date(5, 9),  flag: "🇺🇸", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 7,  name: "Emilia Romagna Grand Prix",   circuit: "Autodromo Enzo e Dino Ferrari",     country: "Italy",        city: "Imola",        raceDate: date(5, 24), qualifyingDate: date(5, 23), flag: "🇮🇹", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 8,  name: "Monaco Grand Prix",           circuit: "Circuit de Monaco",                 country: "Monaco",       city: "Monte Carlo",  raceDate: date(5, 31), qualifyingDate: date(5, 30), flag: "🇲🇨", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 9,  name: "Spanish Grand Prix",          circuit: "Circuit de Barcelona-Catalunya",    country: "Spain",        city: "Barcelona",    raceDate: date(6, 14), qualifyingDate: date(6, 13), flag: "🇪🇸", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 10, name: "Canadian Grand Prix",         circuit: "Circuit Gilles Villeneuve",         country: "Canada",       city: "Montreal",     raceDate: date(6, 21), qualifyingDate: date(6, 20), flag: "🇨🇦", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 11, name: "Austrian Grand Prix",         circuit: "Red Bull Ring",                     country: "Austria",      city: "Spielberg",    raceDate: date(7, 5),  qualifyingDate: date(7, 4),  flag: "🇦🇹", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 12, name: "British Grand Prix",          circuit: "Silverstone Circuit",               country: "UK",           city: "Silverstone",  raceDate: date(7, 12), qualifyingDate: date(7, 11), flag: "🇬🇧", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 13, name: "Belgian Grand Prix",          circuit: "Circuit de Spa-Francorchamps",      country: "Belgium",      city: "Spa",          raceDate: date(7, 26), qualifyingDate: date(7, 25), flag: "🇧🇪", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 14, name: "Hungarian Grand Prix",        circuit: "Hungaroring",                       country: "Hungary",      city: "Budapest",     raceDate: date(8, 2),  qualifyingDate: date(8, 1),  flag: "🇭🇺", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 15, name: "Dutch Grand Prix",            circuit: "Circuit Zandvoort",                 country: "Netherlands",  city: "Zandvoort",    raceDate: date(8, 30), qualifyingDate: date(8, 29), flag: "🇳🇱", winner: nil, winnerTeam: nil, fastestLap: nil),
            F1Race(round: 16, name: "Italian Grand Prix",          circuit: "Autodromo Nazionale di Monza",      country: "Italy",        city: "Monza",        raceDate: date(9, 6),  qualifyingDate: date(9, 5),  flag: "🇮🇹", winner: nil, winnerTeam: nil, fastestLap: nil),
        ]
    }()

    static var upcoming: [F1Race] { season2026.filter { $0.isUpcoming } }
    static var past: [F1Race] { season2026.filter { $0.isPast }.reversed() }
}
