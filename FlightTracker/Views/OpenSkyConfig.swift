import Foundation

/// Configuration for OpenSky Network API and alternative flight data sources
struct OpenSkyConfig {
    // MARK: - Authentication
    // OpenSky credentials (environment variables for security)
    // Sign up at: https://opensky-network.org/
    // 
    // ⚠️ IMPORTANT NOTE ABOUT ROUTE DATA:
    // The /api/flights/aircraft endpoint returns 403 for most users.
    // This endpoint requires "contributor" status - you need to set up an
    // ADS-B receiver and contribute data to OpenSky.
    // See: https://opensky-network.org/contribute
    //
    // Without contributor status, route data will NOT be available.
    // Consider using alternative APIs like AviationStack or FlightAware.
    
    static let username: String? = ProcessInfo.processInfo.environment["OPENSKY_USERNAME"]
    static let password: String? = ProcessInfo.processInfo.environment["OPENSKY_PASSWORD"]
    
    /// Returns the Basic Authentication header value if credentials are provided
    static var authorizationHeader: String? {
        guard let username = username,
              let password = password,
              !username.isEmpty,
              !password.isEmpty else {
            return nil
        }
        
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            return nil
        }
        
        let base64Credentials = credentialsData.base64EncodedString()
        return "Basic \(base64Credentials)"
    }
    
    static var isAuthenticated: Bool {
        authorizationHeader != nil
    }
    
    // MARK: - Alternative Data Sources
    
    /// Whether to use alternative APIs for route data (recommended)
    static let useAlternativeRouteData = true
    
    /// AviationStack API key (free tier: 500 requests/month)
    /// Sign up at: https://aviationstack.com/
    static let aviationStackAPIKey: String? = ProcessInfo.processInfo.environment["AVIATIONSTACK_API_KEY"]
    
    /// Whether to attempt OpenSky route lookups despite known limitations
    /// Set to false to save API quota if you don't have contributor status
    static let attemptOpenSkyRoutes = false
    
    // MARK: - Feature Flags
    
    /// Enable verbose logging for debugging API issues
    static let verboseLogging = true
}
