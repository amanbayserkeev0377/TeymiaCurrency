import Foundation

// Model for API response
struct ExchangeRateResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
    
    enum CodingKeys: String, CodingKey {
        case base, date, rates
    }
}
