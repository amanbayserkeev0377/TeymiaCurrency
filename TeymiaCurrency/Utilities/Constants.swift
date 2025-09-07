import Foundation

struct Constants {
    
    // MARK: - API Configuration
    
    struct API {
        static let exchangeRateBaseURL = "https://api.exchangerate-api.com/v4"
        static let coinGeckoBaseURL = "https://api.coingecko.com/api/v3"
        
        // Rate limits
        static let requestTimeout: TimeInterval = 10.0
        static let maxRetryCount = 3
    }
    
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
        static let name = "Teymia Currency"
        static let version = "1.0"
        static let buildNumber = "1"
        
        // Default currencies for first launch
        static let defaultCurrencies = ["USD", "CNY", "RUB", "BTC"]
        
        // Maximum number of currencies user can add
        static let maxCurrencies = 50
        
        // Minimum refresh interval (to prevent API abuse)
        static let minRefreshInterval: TimeInterval = 60
    }
    
    // MARK: - UI Configuration
    
    struct UI {
        // Animation durations
        static let quickAnimation: Double = 0.2
        static let standardAnimation: Double = 0.3
        static let slowAnimation: Double = 0.5
        
        // Spacing
        static let smallSpacing: CGFloat = 8
        static let standardSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 24
        
        // Corner radius
        static let smallCornerRadius: CGFloat = 8
        static let standardCornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 16
        
        // FAB button
        static let fabButtonSize: CGFloat = 60
        static let fabButtonMargin: CGFloat = 20
        
        // Currency icon size
        static let currencyIconSize: CGFloat = 32
        static let largeCurrencyIconSize: CGFloat = 40
    }
    
    // MARK: - Formatting
    
    struct Formatting {
        static let maxFiatDecimals = 2
        static let maxCryptoDecimals = 6
        static let minCryptoDecimals = 2
        
        // Large number formatting
        static let thousandSeparator = ","
        static let decimalSeparator = "."
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
    
    // MARK: - Analytics Events (if you add analytics later)
    
    struct Analytics {
        static let currencyAdded = "currency_added"
        static let currencyRemoved = "currency_removed"
        static let ratesRefreshed = "rates_refreshed"
        static let settingsOpened = "settings_opened"
        static let aboutViewed = "about_viewed"
    }
    
    // MARK: - Debug
    
    struct Debug {
        static let enableAPILogging = true
        static let enablePerformanceLogging = false
        static let mockAPIResponses = false
    }
}
