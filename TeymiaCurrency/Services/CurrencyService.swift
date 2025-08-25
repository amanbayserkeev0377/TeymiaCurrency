import Foundation

class CurrencyService {
    static let shared = CurrencyService()
    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    private let selectedCurrenciesKey = "selectedCurrencies"
    private let lastRatesKey = "lastRates"
    private let lastUpdateKey = "lastUpdate"
    
    private init() {}
    
    func fetchLatestRates(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let selectedCurrencies = loadSelectedCurrencies()
        let currencyCodes = selectedCurrencies.map { $0.code }
        
        if !currencyCodes.isEmpty {
            apiService.fetchMultipleRates(from: "USD", to: currencyCodes) { result in
                switch result {
                case .success(let response):
                    self.saveRates(response.rates)
                    completion(.success(response.rates))
                case .failure(let error):
                    print("API error: \(error)")
                    if let cachedRates = self.loadCachedRates() {
                        completion(.success(cachedRates))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        } else {
            let mockResponse = apiService.getMockRates()
            completion(.success(mockResponse.rates))
        }
    }
    
    func convertAmount(_ amount: Double, from: String, to: String, completion: @escaping (Result<Double, Error>) -> Void) {
        apiService.convertAmount(amount: amount, from: from, to: to, completion: completion)
    }
    
    private func saveRates(_ rates: [String: Double]) {
        do {
            let data = try JSONEncoder().encode(rates)
            userDefaults.set(data, forKey: lastRatesKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        } catch {
            print("Error saving rates: \(error)")
        }
    }
    
    private func loadCachedRates() -> [String: Double]? {
        guard let data = userDefaults.data(forKey: lastRatesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return nil
        }
        return rates
    }
    
    func saveSelectedCurrencies(_ currencies: [Currency]) {
        do {
            let data = try JSONEncoder().encode(currencies)
            userDefaults.set(data, forKey: selectedCurrenciesKey)
        } catch {
            print("Error saving currencies: \(error)")
        }
    }
    
    func loadSelectedCurrencies() -> [Currency] {
        guard let data = userDefaults.data(forKey: selectedCurrenciesKey),
              let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
            return [
                CurrencyData.findCurrency(by: "USD")!,
                CurrencyData.findCurrency(by: "EUR")!,
                CurrencyData.findCurrency(by: "KZT")!,
                CurrencyData.findCurrency(by: "RUB")!
            ]
        }
        return currencies
    }
    
    func addCurrency(_ currency: Currency) {
        var currentCurrencies = loadSelectedCurrencies()
        if !currentCurrencies.contains(where: { $0.code == currency.code }) {
            currentCurrencies.append(currency)
            saveSelectedCurrencies(currentCurrencies)
        }
    }
    
    func removeCurrency(at index: Int) {
        var currentCurrencies = loadSelectedCurrencies()
        currentCurrencies.remove(at: index)
        saveSelectedCurrencies(currentCurrencies)
    }
    
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
    
    private var selectedCurrencies: [Currency] = [
        CurrencyData.findCurrency(by: "USD")!,
        CurrencyData.findCurrency(by: "EUR")!,
        CurrencyData.findCurrency(by: "KZT")!,
        CurrencyData.findCurrency(by: "RUB")!
    ]
}
