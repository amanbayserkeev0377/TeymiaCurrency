import Foundation

struct Constants {
        
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKeys {
        static let selectedCurrencies = "selectedCurrencies"
        static let lastRates = "lastRates"
        static let lastUpdateTime = "lastUpdateTime"
        static let autoRefreshEnabled = "autoRefreshEnabled"
        static let refreshInterval = "refreshInterval"
        static let baseCurrency = "baseCurrency"
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    // MARK: - App Configuration
    
    struct App {
        // Default currencies for first launch
        static let defaultCurrencies = ["USD", "CNY", "RUB", "BTC"]
        
        // Maximum number of currencies user can add
        static let maxCurrencies = 50
    }
            
    // MARK: - Error Messages
    
    struct ErrorMessages {
        static let networkUnavailable = "Network connection is unavailable"
        static let apiError = "Unable to fetch exchange rates"
        static let invalidAmount = "Please enter a valid amount"
        static let currencyNotFound = "Currency not found"
        static let maxCurrenciesReached = "Maximum number of currencies reached"
        static let unknownError = "An unknown error occurred"
    }
    
    // MARK: - Debug
    
    struct Debug {
        static let enableAPILogging = true
        static let enablePerformanceLogging = false
        static let mockAPIResponses = false
    }
}
