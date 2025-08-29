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
        
        if !selectedCurrencies.isEmpty {
            apiService.fetchRatesForCurrencies(selectedCurrencies) { [weak self] result in
                switch result {
                case .success(let rates):
                    self?.saveRates(rates)
                    completion(.success(rates))
                case .failure(let error):
                    print("API error: \(error)")
                    // Try to return cached rates on error
                    if let cachedRates = self?.loadCachedRates() {
                        completion(.success(cachedRates))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        } else {
            // Return empty rates if no currencies selected
            completion(.success([:]))
        }
    }
    
    func convertAmount(_ amount: Double, from: String, to: String, completion: @escaping (Result<Double, Error>) -> Void) {
        // For conversion, we need to handle fiat-to-fiat, crypto-to-fiat, etc.
        // This is a simplified version - you might want to expand this
        fetchLatestRates { result in
            switch result {
            case .success(let rates):
                guard let fromRate = rates[from], let toRate = rates[to] else {
                    completion(.failure(NSError(domain: "CurrencyService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Currency rates not available"])))
                    return
                }
                
                // Convert: amount * (toRate / fromRate)
                let convertedAmount = amount * (toRate / fromRate)
                completion(.success(convertedAmount))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Data Persistence
    
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
            // Default currencies if none saved
            return [
                CurrencyData.findCurrency(by: "USD")!,
                CurrencyData.findCurrency(by: "EUR")!,
                CurrencyData.findCurrency(by: "KZT")!,
                CurrencyData.findCurrency(by: "BTC")!
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
        guard index < currentCurrencies.count else { return }
        currentCurrencies.remove(at: index)
        saveSelectedCurrencies(currentCurrencies)
    }
    
    // MARK: - Currency Data
    
    func getAvailableCurrencies(for type: Currency.CurrencyType) -> [Currency] {
        return CurrencyData.getCurrencies(for: type)
    }
    
    func getCurrencyIcon(for currency: Currency) -> String {
        if currency.type == .fiat {
            // For fiat currencies, use currency code directly (matches your assets)
            return currency.code
        } else {
            // For crypto, use lowercase code or specific mapping
            return getCryptoIconName(for: currency.code)
        }
    }
    
    private func getCryptoIconName(for cryptoCode: String) -> String {
        // Map crypto codes to icon names in your assets
        // Adjust based on how you name crypto icons
        let cryptoIcons: [String: String] = [
            "BTC": "BTC",
            "ETH": "ETH",
            "BNB": "BNB",
            "ADA": "ADA",
            "XRP": "XRP",
            "DOGE": "DOGE",
            "DOT": "DOT",
            "SOL": "SOL",
            "MATIC": "MATIC",
            "LINK": "LINK",
            "LTC": "LTC",
            "AVAX": "AVAX",
            "UNI": "UNI",
            "ATOM": "ATOM"
        ]
        
        return cryptoIcons[cryptoCode] ?? cryptoCode.lowercased()
    }
    
    // MARK: - Cached Exchange Rates Access
    
    func getLastUpdateTime() -> Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }
}
