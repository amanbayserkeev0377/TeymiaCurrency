import Foundation

struct ConversionResult {
    let amount: Double
    let fromCurrency: Currency
    let toCurrency: Currency
    let convertedAmount: Double
    let rate: Double
    let timestamp: Date
}
