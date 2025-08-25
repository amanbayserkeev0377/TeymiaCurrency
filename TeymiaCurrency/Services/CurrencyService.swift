import Foundation

class CurrencyService {
    static let shared = CurrencyService()
    
    private init() {}
    
    // MARK: - Mock Data
    func getAvailableCurrencies(for type: Currency.CurrencyType) -> [Currency] {
        return CurrencyData.getCurrencies(for: type)
    }
    
    func getExchangeRate(from: String, to: String) -> Double {
        let testRates: [String: Double] = [
            "USD_EUR": 0.85,
            "USD_KZT": 450.0,
            "USD_RUB": 75.0,
            "EUR_USD": 1.18,
            "EUR_KZT": 530.0,
            "KZT_USD": 0.0022,
            "KZT_EUR": 0.0019,
            "BTC_USD": 50000.0
        ]
        
        let key = "\(from)_\(to)"
        return testRates[key] ?? 1.0
    }
    
    func saveSelectedCurrencies(_ currencies: [Currency]) {
        selectedCurrencies = currencies
    }
    
    func loadSelectedCurrencies() -> [Currency] {
        return selectedCurrencies
    }
    
    private var selectedCurrencies: [Currency] = [
        CurrencyData.findCurrency(by: "USD")!,
        CurrencyData.findCurrency(by: "EUR")!,
        CurrencyData.findCurrency(by: "KZT")!,
        CurrencyData.findCurrency(by: "RUB")!
    ]
}
