import Foundation

/// Service handling currency business logic, data persistence, and API coordination
class CurrencyService {
    
    // MARK: - Singleton
    
    static let shared = CurrencyService()
    
    // MARK: - Dependencies
    
    private let apiService = APIService.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - UserDefaults Keys
    
    private let selectedCurrenciesKey = "selectedCurrencies"
    private let lastRatesKey = "lastRates"
    private let lastUpdateKey = "lastUpdate"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods - Exchange Rates
    
    /// Fetches latest exchange rates for all selected currencies
    /// - Parameter completion: Completion handler with rates dictionary or error
    func fetchLatestRates(completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let selectedCurrencies = loadSelectedCurrencies()
        
        guard !selectedCurrencies.isEmpty else {
            completion(.success([:]))
            return
        }
        
        apiService.fetchRatesForCurrencies(selectedCurrencies) { [weak self] result in
            switch result {
            case .success(let rates):
                self?.saveRates(rates)
                completion(.success(rates))
            case .failure(let error):
                // Fallback to cached rates on network error
                if let cachedRates = self?.loadCachedRates() {
                    completion(.success(cachedRates))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Converts amount between two currencies
    /// - Parameters:
    ///   - amount: Amount to convert
    ///   - from: Source currency code
    ///   - to: Target currency code
    ///   - completion: Completion handler with converted amount or error
    func convertAmount(
        _ amount: Double,
        from: String,
        to: String,
        completion: @escaping (Result<Double, Error>) -> Void
    ) {
        fetchLatestRates { result in
            switch result {
            case .success(let rates):
                guard let fromRate = rates[from], let toRate = rates[to] else {
                    let error = NSError(
                        domain: "CurrencyService",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Currency rates not available"]
                    )
                    completion(.failure(error))
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
    
    /// Returns the timestamp of the last successful rates update
    /// - Returns: Date of last update or nil if never updated
    func getLastUpdateTime() -> Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }
    
    // MARK: - Public Methods - Currency Management
    
    /// Saves selected currencies to persistent storage
    /// - Parameter currencies: Array of currencies to save
    func saveSelectedCurrencies(_ currencies: [Currency]) {
        do {
            let data = try JSONEncoder().encode(currencies)
            userDefaults.set(data, forKey: selectedCurrenciesKey)
        } catch {
            print("Error saving currencies: \(error)")
        }
    }
    
    /// Loads selected currencies from persistent storage
    /// - Returns: Array of currencies, or default currencies if none saved
    func loadSelectedCurrencies() -> [Currency] {
        guard let data = userDefaults.data(forKey: selectedCurrenciesKey),
              let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
            return defaultCurrencies
        }
        return currencies
    }
    
    /// Adds a new currency to the selected list
    /// - Parameter currency: Currency to add
    func addCurrency(_ currency: Currency) {
        var currentCurrencies = loadSelectedCurrencies()
        if !currentCurrencies.contains(where: { $0.code == currency.code }) {
            currentCurrencies.append(currency)
            saveSelectedCurrencies(currentCurrencies)
        }
    }
    
    /// Removes a currency at specified index
    /// - Parameter index: Index of currency to remove
    func removeCurrency(at index: Int) {
        var currentCurrencies = loadSelectedCurrencies()
        guard index < currentCurrencies.count else { return }
        currentCurrencies.remove(at: index)
        saveSelectedCurrencies(currentCurrencies)
    }
    
    // MARK: - Public Methods - Currency Data
    
    /// Returns all available currencies for a specific type
    /// - Parameter type: Currency type (fiat or crypto)
    /// - Returns: Array of available currencies
    func getAvailableCurrencies(for type: Currency.CurrencyType) -> [Currency] {
        return CurrencyData.getCurrencies(for: type)
    }
    
    /// Returns the icon/image name for a currency
    /// - Parameter currency: Currency to get icon for
    /// - Returns: Asset name for the currency icon
    func getCurrencyIcon(for currency: Currency) -> String {
        if currency.type == .fiat {
            return currency.code
        } else {
            return getCryptoIconName(for: currency.code)
        }
    }
    
    // MARK: - Private Methods - Data Persistence
    
    /// Saves exchange rates to UserDefaults cache
    /// - Parameter rates: Dictionary of exchange rates to save
    private func saveRates(_ rates: [String: Double]) {
        do {
            let data = try JSONEncoder().encode(rates)
            userDefaults.set(data, forKey: lastRatesKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        } catch {
            print("Error saving rates: \(error)")
        }
    }
    
    /// Loads cached exchange rates from UserDefaults
    /// - Returns: Dictionary of cached rates or nil if not available
    private func loadCachedRates() -> [String: Double]? {
        guard let data = userDefaults.data(forKey: lastRatesKey),
              let rates = try? JSONDecoder().decode([String: Double].self, from: data) else {
            return nil
        }
        return rates
    }
    
    // MARK: - Private Methods - Icon Management
    
    /// Returns the icon name for a cryptocurrency
    /// - Parameter cryptoCode: Crypto currency code (e.g., "BTC")
    /// - Returns: Asset name for the crypto icon
    private func getCryptoIconName(for cryptoCode: String) -> String {
        // All available crypto icons in Assets.xcassets
        let availableCryptoIcons: Set<String> = [
            "AAVE", "ADA", "ALGO", "APT", "ARB", "ATOM", "AVAX", "AXS", "BCH",
            "BGB", "BNB", "BTC", "BUSD", "CFX", "CRO", "DAI", "DOGE", "DOT",
            "EGLD", "ETC", "ETH", "FIL", "FLR", "GRT", "HBAR", "ICP", "INJ",
            "JLP", "KAS", "LDO", "LEO", "LINK", "LTC", "LUNC", "METH", "NEAR",
            "OP", "POL", "PYTH", "QNT", "RENDER", "SEI", "SHIB", "SOL", "STETH",
            "STX", "SUI", "TAO", "THETA", "TIA", "TON", "TRX", "UNI", "USDC",
            "USDT", "VET", "WBT", "WBTC", "XLM", "XMR", "XRP", "XTZ", "ZEC"
        ]
        
        if availableCryptoIcons.contains(cryptoCode) {
            return cryptoCode
        } else {
            // Fallback to Bitcoin icon for missing crypto icons
            return "BTC"
        }
    }
    
    // MARK: - Default Configuration
    
    /// Default currencies shown on first app launch
    private var defaultCurrencies: [Currency] {
        return [
            CurrencyData.findCurrency(by: "USD")!,
            CurrencyData.findCurrency(by: "CNY")!,
            CurrencyData.findCurrency(by: "RUB")!,
            CurrencyData.findCurrency(by: "BTC")!
        ]
    }
}
