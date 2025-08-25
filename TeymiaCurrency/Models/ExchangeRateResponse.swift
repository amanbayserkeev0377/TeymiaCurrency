import Foundation

struct ExchangeRateResponse: Codable {
    let base: String
    let rates: [String: Double]
    let date: String
}

struct ConversionResult {
    let amount: Double
    let fromCurrency: Currency
    let toCurrency: Currency
    let convertedAmount: Double
    let rate: Double
    let timestamp: Date
}
