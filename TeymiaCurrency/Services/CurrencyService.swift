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
        print("🔍 [DEBUG] CurrencyService.fetchLatestRates called")
        let selectedCurrencies = loadSelectedCurrencies()
        print("🔍 [DEBUG] Selected currencies: \(selectedCurrencies.map { $0.code })")
        
        if !selectedCurrencies.isEmpty {
            print("🔍 [DEBUG] Calling API for \(selectedCurrencies.count) currencies")
            apiService.fetchRatesForCurrencies(selectedCurrencies) { [weak self] result in
                switch result {
                case .success(let rates):
                    print("✅ [DEBUG] CurrencyService got \(rates.count) rates")
                    print("✅ [DEBUG] Rate keys: \(Array(rates.keys))")
                    self?.saveRates(rates)
                    completion(.success(rates))
                case .failure(let error):
                    print("❌ [DEBUG] API error: \(error)")
                    // Try to return cached rates on error
                    if let cachedRates = self?.loadCachedRates() {
                        print("🔄 [DEBUG] Using cached rates: \(cachedRates.count)")
                        completion(.success(cachedRates))
                    } else {
                        print("❌ [DEBUG] No cached rates available")
                        completion(.failure(error))
                    }
                }
            }
        } else {
            print("⚠️ [DEBUG] No currencies selected - returning empty rates")
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
                CurrencyData.findCurrency(by: "CNY")!,
                CurrencyData.findCurrency(by: "RUB")!,
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
    
    // MARK: - Updated getCryptoIconName method for CurrencyService.swift

    private func getCryptoIconName(for cryptoCode: String) -> String {
        // All available crypto icons in your Assets.xcassets
        let availableCryptoIcons: Set<String> = [
            "AAVE", "ADA", "ALGO", "APT", "ARB", "ATOM", "AVAX", "AXS", "BCH",
            "BGB", "BNB", "BTC", "BUSD", "CFX", "CRO", "DAI", "DOGE", "DOT",
            "EGLD", "ETC", "ETH", "FIL", "FLR", "GRT", "HBAR", "ICP", "INJ",
            "JLP", "KAS", "LDO", "LEO", "LINK", "LTC", "LUNC", "METH", "NEAR",
            "OP", "POL", "PYTH", "QNT", "RENDER", "SEI", "SHIB", "SOL", "STETH",
            "STX", "SUI", "TAO", "THETA", "TIA", "TON", "TRX", "UNI", "USDC",
            "USDT", "VET", "WBT", "WBTC", "XLM", "XMR", "XRP", "XTZ", "ZEC"
        ]
        
        // Return icon name if exists, otherwise use generic crypto icon or placeholder
        if availableCryptoIcons.contains(cryptoCode) {
            return cryptoCode
        } else {
            // Fallback to generic crypto icon or SF Symbol
            print("⚠️ Missing crypto icon: \(cryptoCode)")
            return "BTC" // Use Bitcoin as fallback
        }
    }
    
    // MARK: - Cached Exchange Rates Access
    
    func getLastUpdateTime() -> Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }
}
