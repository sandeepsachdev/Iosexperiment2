import Foundation

struct Airport {
    let icao: String
    let iata: String
    let name: String
    let city: String
    let country: String
    let flag: String
}

enum AirportDatabase {
    static func lookup(_ icao: String) -> Airport? {
        all[icao.uppercased()]
    }

    static let all: [String: Airport] = Dictionary(
        uniqueKeysWithValues: airports.map { ($0.icao, $0) }
    )

    // fmt: ICAO, IATA, Name, City, Country, Flag
    private static let airports: [Airport] = [
        // Australia
        Airport(icao:"YSSY", iata:"SYD", name:"Kingsford Smith",          city:"Sydney",       country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YMML", iata:"MEL", name:"Melbourne Airport",         city:"Melbourne",    country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YBBN", iata:"BNE", name:"Brisbane Airport",          city:"Brisbane",     country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YPER", iata:"PER", name:"Perth Airport",             city:"Perth",        country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YPAD", iata:"ADL", name:"Adelaide Airport",          city:"Adelaide",     country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YSCB", iata:"CBR", name:"Canberra Airport",          city:"Canberra",     country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YBCS", iata:"CNS", name:"Cairns Airport",            city:"Cairns",       country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YBMC", iata:"MCY", name:"Sunshine Coast Airport",    city:"Sunshine Coast",country:"Australia",   flag:"🇦🇺"),
        Airport(icao:"YBNA", iata:"BLT", name:"Ballina Byron Gateway",     city:"Ballina",      country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YBTL", iata:"TSV", name:"Townsville Airport",        city:"Townsville",   country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YBHM", iata:"HTI", name:"Hamilton Island Airport",   city:"Hamilton Is.", country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YMEN", iata:"MEB", name:"Essendon Airport",          city:"Essendon",     country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YTMW", iata:"TMW", name:"Tamworth Airport",          city:"Tamworth",     country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YWOL", iata:"WOL", name:"Wollongong Airport",        city:"Wollongong",   country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YORG", iata:"OAG", name:"Orange Airport",            city:"Orange",       country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YDUD", iata:"DBO", name:"Dubbo City Airport",        city:"Dubbo",        country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YDAR", iata:"DRW", name:"Darwin International",      city:"Darwin",       country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YHBA", iata:"HVB", name:"Hervey Bay Airport",        city:"Hervey Bay",   country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YMLT", iata:"LST", name:"Launceston Airport",        city:"Launceston",   country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YMHB", iata:"HBA", name:"Hobart Airport",            city:"Hobart",       country:"Australia",    flag:"🇦🇺"),
        Airport(icao:"YAYE", iata:"ABX", name:"Albury Airport",            city:"Albury",       country:"Australia",    flag:"🇦🇺"),

        // New Zealand
        Airport(icao:"NZAA", iata:"AKL", name:"Auckland Airport",          city:"Auckland",     country:"New Zealand",  flag:"🇳🇿"),
        Airport(icao:"NZWN", iata:"WLG", name:"Wellington Airport",        city:"Wellington",   country:"New Zealand",  flag:"🇳🇿"),
        Airport(icao:"NZCH", iata:"CHC", name:"Christchurch Airport",      city:"Christchurch", country:"New Zealand",  flag:"🇳🇿"),
        Airport(icao:"NZQN", iata:"ZQN", name:"Queenstown Airport",        city:"Queenstown",   country:"New Zealand",  flag:"🇳🇿"),
        Airport(icao:"NZDN", iata:"DUD", name:"Dunedin Airport",           city:"Dunedin",      country:"New Zealand",  flag:"🇳🇿"),

        // Pacific / Oceania
        Airport(icao:"NFFN", iata:"NAN", name:"Nadi International",        city:"Nadi",         country:"Fiji",         flag:"🇫🇯"),
        Airport(icao:"AYPY", iata:"POM", name:"Jacksons International",    city:"Port Moresby", country:"Papua NG",     flag:"🇵🇬"),
        Airport(icao:"NVVV", iata:"VLI", name:"Bauerfield International",  city:"Port Vila",    country:"Vanuatu",      flag:"🇻🇺"),

        // Asia – East
        Airport(icao:"VHHH", iata:"HKG", name:"Hong Kong International",   city:"Hong Kong",    country:"Hong Kong",    flag:"🇭🇰"),
        Airport(icao:"RCTP", iata:"TPE", name:"Taiwan Taoyuan Intl",        city:"Taipei",       country:"Taiwan",       flag:"🇹🇼"),
        Airport(icao:"RJTT", iata:"HND", name:"Haneda Airport",             city:"Tokyo",        country:"Japan",        flag:"🇯🇵"),
        Airport(icao:"RJAA", iata:"NRT", name:"Narita International",       city:"Tokyo",        country:"Japan",        flag:"🇯🇵"),
        Airport(icao:"RJOO", iata:"ITM", name:"Osaka Itami Airport",        city:"Osaka",        country:"Japan",        flag:"🇯🇵"),
        Airport(icao:"RKSI", iata:"ICN", name:"Incheon International",      city:"Seoul",        country:"South Korea",  flag:"🇰🇷"),
        Airport(icao:"ZBAA", iata:"PEK", name:"Beijing Capital Intl",       city:"Beijing",      country:"China",        flag:"🇨🇳"),
        Airport(icao:"ZSPD", iata:"PVG", name:"Shanghai Pudong Intl",       city:"Shanghai",     country:"China",        flag:"🇨🇳"),
        Airport(icao:"ZGGG", iata:"CAN", name:"Guangzhou Baiyun Intl",      city:"Guangzhou",    country:"China",        flag:"🇨🇳"),

        // Asia – Southeast
        Airport(icao:"WSSS", iata:"SIN", name:"Singapore Changi",           city:"Singapore",    country:"Singapore",    flag:"🇸🇬"),
        Airport(icao:"WMKK", iata:"KUL", name:"Kuala Lumpur Intl",          city:"Kuala Lumpur", country:"Malaysia",     flag:"🇲🇾"),
        Airport(icao:"VTBS", iata:"BKK", name:"Suvarnabhumi Airport",       city:"Bangkok",      country:"Thailand",     flag:"🇹🇭"),
        Airport(icao:"RPLL", iata:"MNL", name:"Ninoy Aquino Intl",          city:"Manila",       country:"Philippines",  flag:"🇵🇭"),
        Airport(icao:"WIII", iata:"CGK", name:"Soekarno-Hatta Intl",        city:"Jakarta",      country:"Indonesia",    flag:"🇮🇩"),
        Airport(icao:"WADD", iata:"DPS", name:"Ngurah Rai Intl (Bali)",     city:"Denpasar",     country:"Indonesia",    flag:"🇮🇩"),
        Airport(icao:"VVTS", iata:"SGN", name:"Tan Son Nhat Intl",          city:"Ho Chi Minh",  country:"Vietnam",      flag:"🇻🇳"),

        // Asia – South
        Airport(icao:"VIDP", iata:"DEL", name:"Indira Gandhi Intl",         city:"New Delhi",    country:"India",        flag:"🇮🇳"),
        Airport(icao:"VABB", iata:"BOM", name:"Chhatrapati Shivaji Intl",   city:"Mumbai",       country:"India",        flag:"🇮🇳"),

        // Middle East
        Airport(icao:"OMDB", iata:"DXB", name:"Dubai International",        city:"Dubai",        country:"UAE",          flag:"🇦🇪"),
        Airport(icao:"OMDW", iata:"DWC", name:"Al Maktoum International",   city:"Dubai",        country:"UAE",          flag:"🇦🇪"),
        Airport(icao:"OTHH", iata:"DOH", name:"Hamad International",        city:"Doha",         country:"Qatar",        flag:"🇶🇦"),
        Airport(icao:"OEJN", iata:"JED", name:"King Abdulaziz Intl",        city:"Jeddah",       country:"Saudi Arabia", flag:"🇸🇦"),

        // Africa
        Airport(icao:"FAOR", iata:"JNB", name:"O.R. Tambo International",   city:"Johannesburg", country:"South Africa", flag:"🇿🇦"),

        // Europe
        Airport(icao:"EGLL", iata:"LHR", name:"Heathrow Airport",           city:"London",       country:"UK",           flag:"🇬🇧"),
        Airport(icao:"EDDF", iata:"FRA", name:"Frankfurt Airport",           city:"Frankfurt",    country:"Germany",      flag:"🇩🇪"),
        Airport(icao:"LFPG", iata:"CDG", name:"Charles de Gaulle Airport",  city:"Paris",        country:"France",       flag:"🇫🇷"),
        Airport(icao:"EHAM", iata:"AMS", name:"Amsterdam Schiphol",         city:"Amsterdam",    country:"Netherlands",  flag:"🇳🇱"),

        // North America
        Airport(icao:"KLAX", iata:"LAX", name:"Los Angeles Intl",           city:"Los Angeles",  country:"USA",          flag:"🇺🇸"),
        Airport(icao:"KSFO", iata:"SFO", name:"San Francisco Intl",         city:"San Francisco",country:"USA",          flag:"🇺🇸"),
        Airport(icao:"KJFK", iata:"JFK", name:"John F. Kennedy Intl",       city:"New York",     country:"USA",          flag:"🇺🇸"),
        Airport(icao:"KDFW", iata:"DFW", name:"Dallas/Fort Worth Intl",     city:"Dallas",       country:"USA",          flag:"🇺🇸"),
        Airport(icao:"CYYZ", iata:"YYZ", name:"Toronto Pearson Intl",       city:"Toronto",      country:"Canada",       flag:"🇨🇦"),
        Airport(icao:"CYVR", iata:"YVR", name:"Vancouver Intl",             city:"Vancouver",    country:"Canada",       flag:"🇨🇦"),
    ]
}
