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
    private let currencyService = CurrencyService.shared
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSelectedCurrencies()
        loadCachedRates()
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
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func fetchRatesIfNeeded() {
        if exchangeRates.isEmpty || shouldRefreshRates() {
            fetchRates()
        }
    }
    
    private func shouldRefreshRates() -> Bool {
        guard let lastUpdate = lastUpdateTime else { return true }
        return Date().timeIntervalSince(lastUpdate) > 3600
    }
    
    private func fetchRatesAsync() async throws -> [String: Double] {
        return try await withCheckedThrowingContinuation { continuation in
            currencyService.fetchLatestRates { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - Convertation Logic
    func updateAmount(_ amount: Double, for currencyCode: String) {
        editingCurrency = currencyCode
        
        if currencyCode == "USD" {
            baseAmount = amount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            baseAmount = amount / rate
        }
    }
    
    func getDisplayAmount(for currencyCode: String) -> Double {
        if currencyCode == "USD" {
            return baseAmount
        } else {
            let rate = getExchangeRate(for: currencyCode)
            return baseAmount * rate
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
