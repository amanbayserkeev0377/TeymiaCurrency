import SwiftUI
import Foundation

@MainActor
class CurrencyStore: ObservableObject {
    @Published var selectedCurrencies: [Currency] = [] {
        didSet {
            saveCurrencies()
        }
    }
    @Published var exchangeRates: [String: Double] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime: Date?
    
    @Published var baseAmount: Double = 1.0
    @Published var editingCurrency: String = "USD"
    @Published var isFirstLaunch: Bool = false
    
    @Published var focusedCurrencyCode: String? = nil
    
    private let currencyService = CurrencyService.shared
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSelectedCurrencies()
        loadCachedRates()
        
        // Check if this is first launch
        isFirstLaunch = exchangeRates.isEmpty
        
        print("🔍 [DEBUG] Loaded \(selectedCurrencies.count) currencies: \(selectedCurrencies.map { $0.code })")
        print("🔍 [DEBUG] Loaded \(exchangeRates.count) cached rates")
        print("🔍 [DEBUG] Is first launch: \(isFirstLaunch)")
    }
    
    // MARK: - Currency Management
    
    func loadSelectedCurrencies() {
        selectedCurrencies = currencyService.loadSelectedCurrencies()
    }
    
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
    
    func removeCurrency(_ currency: Currency) {
        selectedCurrencies.removeAll { $0.code == currency.code }
        saveCurrencies()
    }
    
    var canRemoveMore: Bool {
        return selectedCurrencies.count > 1
    }
    
    func moveCurrency(from source: IndexSet, to destination: Int) {
        selectedCurrencies.move(fromOffsets: source, toOffset: destination)
        saveCurrencies()
    }
    
    private func saveCurrencies() {
        currencyService.saveSelectedCurrencies(selectedCurrencies)
    }
    
    // MARK: - Exchange Rates
    
    func fetchRates() {
        print("🚀 [DEBUG] fetchRates() called")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let rates = try await fetchRatesAsync()
                print("✅ [DEBUG] Got \(rates.count) rates in fetchRates")
                await MainActor.run {
                    self.exchangeRates = rates
                    self.lastUpdateTime = Date()
                    self.saveRates(rates)
                    self.isLoading = false
                    self.isFirstLaunch = false
                    print("✅ [DEBUG] UI updated with rates")
                }
            } catch {
                print("❌ [DEBUG] Error in fetchRates: \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.isFirstLaunch = false
                }
            }
        }
    }
    
    func fetchRatesIfNeeded() {
        print("🔍 [DEBUG] fetchRatesIfNeeded called")
        
        let missingRates = selectedCurrencies.filter { currency in
            !exchangeRates.keys.contains(currency.code)
        }
        
        if exchangeRates.isEmpty || shouldRefreshRates() || !missingRates.isEmpty {
            print("🔍 [DEBUG] Starting fetchRates...")
            fetchRates()
        } else {
            print("🔍 [DEBUG] Skipping fetch - all rates are fresh")
        }
    }
    
    private func shouldRefreshRates() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 21600 // 6 hr
    }
    
    private func fetchRatesAsync() async throws -> [String: Double] {
        return try await withCheckedThrowingContinuation { continuation in
            currencyService.fetchLatestRates { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Conversion Logic
    func updateAmount(_ amount: Double, for currencyCode: String) {
        print("🔍 [DEBUG] updateAmount: \(amount) for \(currencyCode)")
        editingCurrency = currencyCode
        
        if currencyCode == "USD" {
            baseAmount = amount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            let currency = selectedCurrencies.first { $0.code == currencyCode }
            
            if currency?.type == .crypto {
                baseAmount = amount * rate
            } else {
                baseAmount = amount / rate
            }
        }
        print("🔍 [DEBUG] New baseAmount: \(baseAmount)")
    }

    func getDisplayAmount(for currencyCode: String) -> Double {
        if currencyCode == "USD" {
            return baseAmount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            let currency = selectedCurrencies.first { $0.code == currencyCode }
            
            if currency?.type == .crypto {
                return baseAmount / rate
            } else {
                return baseAmount * rate
            }
        }
    }
    
    func getExchangeRate(for currencyCode: String) -> Double {
        return exchangeRates[currencyCode] ?? 1.0
    }
    
    // MARK: - Data Persistence
    
    private func saveRates(_ rates: [String: Double]) {
        userDefaults.setCodable(rates, forKey: Constants.UserDefaultsKeys.lastRates)
        userDefaults.set(Date(), forKey: Constants.UserDefaultsKeys.lastUpdateTime)
    }
    
    private func loadCachedRates() {
        if let rates = userDefaults.getCodable([String: Double].self, forKey: Constants.UserDefaultsKeys.lastRates) {
            exchangeRates = rates
        }
        
        if let date = userDefaults.object(forKey: Constants.UserDefaultsKeys.lastUpdateTime) as? Date {
            lastUpdateTime = date
        }
    }
    
    // MARK: - Computed Properties
    
    var needsUpdate: Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return lastUpdate.isOlderThan(minutes: 60)
    }
    
    var lastUpdateString: String {
        guard let lastUpdate = lastUpdateTime else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}
