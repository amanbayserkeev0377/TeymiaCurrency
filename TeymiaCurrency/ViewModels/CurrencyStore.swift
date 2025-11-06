import SwiftUI
import Foundation

/// Main ViewModel managing currency data, exchange rates, and conversion logic
@MainActor
class CurrencyStore: ObservableObject {
    
    // MARK: - Published Properties
    
    /// List of currencies selected by the user
    @Published var selectedCurrencies: [Currency] = [] {
        didSet {
            saveCurrencies()
        }
    }
    
    /// Current exchange rates for all currencies (key: currency code, value: rate to USD)
    @Published var exchangeRates: [String: Double] = [:]
    
    /// Indicates whether exchange rates are currently being fetched
    @Published var isLoading = false
    
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Timestamp of the last successful rates update
    @Published var lastUpdateTime: Date?
    
    /// Base amount in USD for conversion calculations
    @Published var baseAmount: Double = 1.0
    
    /// Currency code currently being edited by the user
    @Published var editingCurrency: String = "USD"
    
    /// Flag indicating if this is the first app launch (no cached rates)
    @Published var isFirstLaunch: Bool = false
    
    // MARK: - Dependencies
    
    private let currencyService = CurrencyService.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    init() {
        loadSelectedCurrencies()
        loadCachedRates()
        
        // Check if this is first launch (no cached rates available)
        isFirstLaunch = exchangeRates.isEmpty
    }
    
    // MARK: - Currency Management
    
    /// Loads selected currencies from persistent storage
    func loadSelectedCurrencies() {
        selectedCurrencies = currencyService.loadSelectedCurrencies()
    }
    
    /// Adds a new currency to the selected list
    /// - Parameter currency: Currency to add
    func addCurrency(_ currency: Currency) {
        guard !selectedCurrencies.contains(where: { $0.code == currency.code }) else { return }
        guard selectedCurrencies.count < Constants.App.maxCurrencies else {
            errorMessage = Constants.ErrorMessages.maxCurrenciesReached
            return
        }
        
        selectedCurrencies.append(currency)
        saveCurrencies()
        fetchRatesIfNeeded()
    }
    
    /// Removes a currency from the selected list
    /// - Parameter currency: Currency to remove
    func removeCurrency(_ currency: Currency) {
        selectedCurrencies.removeAll { $0.code == currency.code }
        saveCurrencies()
    }
    
    /// Indicates whether more currencies can be removed (minimum 1 required)
    var canRemoveMore: Bool {
        return selectedCurrencies.count > 1
    }
    
    /// Reorders currencies in the list
    /// - Parameters:
    ///   - source: Source index set
    ///   - destination: Destination index
    func moveCurrency(from source: IndexSet, to destination: Int) {
        selectedCurrencies.move(fromOffsets: source, toOffset: destination)
        saveCurrencies()
    }
    
    /// Persists selected currencies to UserDefaults
    private func saveCurrencies() {
        currencyService.saveSelectedCurrencies(selectedCurrencies)
    }
    
    // MARK: - Exchange Rates
    
    /// Fetches latest exchange rates from API
    func fetchRates() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let rates = try await fetchRatesAsync()
                await MainActor.run {
                    self.exchangeRates = rates
                    self.lastUpdateTime = Date()
                    self.saveRates(rates)
                    self.isLoading = false
                    self.isFirstLaunch = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.isFirstLaunch = false
                }
            }
        }
    }
    
    /// Fetches rates only if needed (based on cache age or missing currencies)
    func fetchRatesIfNeeded() {
        let missingRates = selectedCurrencies.filter { currency in
            !exchangeRates.keys.contains(currency.code)
        }
        
        if exchangeRates.isEmpty || shouldRefreshRates() || !missingRates.isEmpty {
            fetchRates()
        }
    }
    
    /// Checks if rates should be refreshed based on last update time
    /// - Returns: True if rates are older than 6 hours
    private func shouldRefreshRates() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 21600 // 6 hours
    }
    
    /// Async wrapper for fetchLatestRates callback
    private func fetchRatesAsync() async throws -> [String: Double] {
        return try await withCheckedThrowingContinuation { continuation in
            currencyService.fetchLatestRates { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Conversion Logic
    
    /// Updates the base amount based on user input in a specific currency
    /// - Parameters:
    ///   - amount: Amount entered by user
    ///   - currencyCode: Currency code being edited
    func updateAmount(_ amount: Double, for currencyCode: String) {
        editingCurrency = currencyCode
        
        if currencyCode == "USD" {
            baseAmount = amount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            let currency = selectedCurrencies.first { $0.code == currencyCode }
            
            if currency?.type == .crypto {
                // For crypto: multiply by rate (crypto is priced in USD)
                baseAmount = amount * rate
            } else {
                // For fiat: divide by rate (rate is USD per currency)
                baseAmount = amount / rate
            }
        }
    }
    
    /// Calculates the display amount for a given currency
    /// - Parameter currencyCode: Currency code to calculate amount for
    /// - Returns: Converted amount in the specified currency
    func getDisplayAmount(for currencyCode: String) -> Double {
        if currencyCode == "USD" {
            return baseAmount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            let currency = selectedCurrencies.first { $0.code == currencyCode }
            
            if currency?.type == .crypto {
                // For crypto: divide by rate
                return baseAmount / rate
            } else {
                // For fiat: multiply by rate
                return baseAmount * rate
            }
        }
    }
    
    /// Retrieves the exchange rate for a currency
    /// - Parameter currencyCode: Currency code
    /// - Returns: Exchange rate or 1.0 if not found
    func getExchangeRate(for currencyCode: String) -> Double {
        return exchangeRates[currencyCode] ?? 1.0
    }
    
    // MARK: - Data Persistence
    
    /// Saves exchange rates to UserDefaults
    /// - Parameter rates: Dictionary of exchange rates to save
    private func saveRates(_ rates: [String: Double]) {
        userDefaults.setCodable(rates, forKey: Constants.UserDefaultsKeys.lastRates)
        userDefaults.set(Date(), forKey: Constants.UserDefaultsKeys.lastUpdateTime)
    }
    
    /// Loads cached exchange rates from UserDefaults
    private func loadCachedRates() {
        if let rates = userDefaults.getCodable([String: Double].self, forKey: Constants.UserDefaultsKeys.lastRates) {
            exchangeRates = rates
        }
        
        if let date = userDefaults.object(forKey: Constants.UserDefaultsKeys.lastUpdateTime) as? Date {
            lastUpdateTime = date
        }
    }
    
    // MARK: - Computed Properties
    
    /// Indicates if rates need updating (older than 1 hour)
    var needsUpdate: Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return lastUpdate.isOlderThan(minutes: 60)
    }
    
    /// Returns a human-readable string of last update time
    var lastUpdateString: String {
        guard let lastUpdate = lastUpdateTime else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}
