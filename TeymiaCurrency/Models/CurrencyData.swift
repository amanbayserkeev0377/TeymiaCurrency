import Foundation

struct CurrencyData {
    static let fiatCurrencies: [Currency] = [
        Currency(code: "USD", name: "US Dollar", type: .fiat),
        Currency(code: "EUR", name: "Euro", type: .fiat),
        Currency(code: "KZT", name: "Kazakhstani Tenge", type: .fiat),
        Currency(code: "RUB", name: "Russian Ruble", type: .fiat),
        Currency(code: "GBP", name: "British Pound", type: .fiat),
        Currency(code: "JPY", name: "Japanese Yen", type: .fiat),
        Currency(code: "CNY", name: "Chinese Yuan", type: .fiat),
        Currency(code: "KRW", name: "South Korean Won", type: .fiat)
    ]
    
    static let cryptoCurrencies: [Currency] = [
        Currency(code: "BTC", name: "Bitcoin", type: .crypto),
        Currency(code: "ETH", name: "Ethereum", type: .crypto),
        Currency(code: "BNB", name: "Binance Coin", type: .crypto),
        Currency(code: "ADA", name: "Cardano", type: .crypto),
        Currency(code: "XRP", name: "Ripple", type: .crypto),
        Currency(code: "DOGE", name: "Dogecoin", type: .crypto),
        Currency(code: "DOT", name: "Polkadot", type: .crypto),
        Currency(code: "SOL", name: "Solana", type: .crypto)
    ]
    
    static func getCurrencies(for type: Currency.CurrencyType) -> [Currency] {
        switch type {
        case .fiat: return fiatCurrencies
        case .crypto: return cryptoCurrencies
        }
    }
    
    static func findCurrency(by code: String) -> Currency? {
        let allCurrencies = fiatCurrencies + cryptoCurrencies
        return allCurrencies.first { $0.code == code }
    }
}

