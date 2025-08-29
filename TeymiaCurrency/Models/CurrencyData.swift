import Foundation

struct CurrencyData {
    static let fiatCurrencies: [Currency] = [
        // Major currencies
        Currency(code: "USD", name: "US Dollar", type: .fiat),
        Currency(code: "EUR", name: "Euro", type: .fiat),
        Currency(code: "GBP", name: "British Pound", type: .fiat),
        Currency(code: "JPY", name: "Japanese Yen", type: .fiat),
        Currency(code: "CHF", name: "Swiss Franc", type: .fiat),
        Currency(code: "CNY", name: "Chinese Yuan", type: .fiat),
        Currency(code: "CAD", name: "Canadian Dollar", type: .fiat),
        Currency(code: "AUD", name: "Australian Dollar", type: .fiat),
        Currency(code: "NZD", name: "New Zealand Dollar", type: .fiat),
        Currency(code: "SEK", name: "Swedish Krona", type: .fiat),
        Currency(code: "NOK", name: "Norwegian Krone", type: .fiat),
        Currency(code: "DKK", name: "Danish Krone", type: .fiat),
        
        // CIS and Regional
        Currency(code: "RUB", name: "Russian Ruble", type: .fiat),
        Currency(code: "KZT", name: "Kazakhstani Tenge", type: .fiat),
        Currency(code: "UAH", name: "Ukrainian Hryvnia", type: .fiat),
        Currency(code: "BYN", name: "Belarusian Ruble", type: .fiat),
        Currency(code: "GEL", name: "Georgian Lari", type: .fiat),
        Currency(code: "AMD", name: "Armenian Dram", type: .fiat),
        Currency(code: "AZN", name: "Azerbaijani Manat", type: .fiat),
        Currency(code: "KGS", name: "Kyrgyzstani Som", type: .fiat),
        Currency(code: "TJS", name: "Tajikistani Somoni", type: .fiat),
        Currency(code: "TMT", name: "Turkmenistan Manat", type: .fiat),
        Currency(code: "UZS", name: "Uzbekistani Som", type: .fiat),
        
        // Asian currencies
        Currency(code: "KRW", name: "South Korean Won", type: .fiat),
        Currency(code: "HKD", name: "Hong Kong Dollar", type: .fiat),
        Currency(code: "SGD", name: "Singapore Dollar", type: .fiat),
        Currency(code: "THB", name: "Thai Baht", type: .fiat),
        Currency(code: "MYR", name: "Malaysian Ringgit", type: .fiat),
        Currency(code: "IDR", name: "Indonesian Rupiah", type: .fiat),
        Currency(code: "PHP", name: "Philippine Peso", type: .fiat),
        Currency(code: "VND", name: "Vietnamese Dong", type: .fiat),
        Currency(code: "INR", name: "Indian Rupee", type: .fiat),
        Currency(code: "PKR", name: "Pakistani Rupee", type: .fiat),
        Currency(code: "BDT", name: "Bangladeshi Taka", type: .fiat),
        Currency(code: "LKR", name: "Sri Lankan Rupee", type: .fiat),
        Currency(code: "NPR", name: "Nepalese Rupee", type: .fiat),
        Currency(code: "BTN", name: "Bhutanese Ngultrum", type: .fiat),
        Currency(code: "MNT", name: "Mongolian Tugrik", type: .fiat),
        
        // Middle East and Africa
        Currency(code: "AED", name: "UAE Dirham", type: .fiat),
        Currency(code: "SAR", name: "Saudi Riyal", type: .fiat),
        Currency(code: "QAR", name: "Qatari Riyal", type: .fiat),
        Currency(code: "KWD", name: "Kuwaiti Dinar", type: .fiat),
        Currency(code: "BHD", name: "Bahraini Dinar", type: .fiat),
        Currency(code: "OMR", name: "Omani Rial", type: .fiat),
        Currency(code: "JOD", name: "Jordanian Dinar", type: .fiat),
        Currency(code: "ILS", name: "Israeli Shekel", type: .fiat),
        Currency(code: "TRY", name: "Turkish Lira", type: .fiat),
        Currency(code: "EGP", name: "Egyptian Pound", type: .fiat),
        Currency(code: "ZAR", name: "South African Rand", type: .fiat),
        Currency(code: "NGN", name: "Nigerian Naira", type: .fiat),
        Currency(code: "KES", name: "Kenyan Shilling", type: .fiat),
        Currency(code: "GHS", name: "Ghanaian Cedi", type: .fiat),
        Currency(code: "MAD", name: "Moroccan Dirham", type: .fiat),
        Currency(code: "TND", name: "Tunisian Dinar", type: .fiat),
        Currency(code: "DZD", name: "Algerian Dinar", type: .fiat),
        Currency(code: "LYD", name: "Libyan Dinar", type: .fiat),
        
        // European currencies
        Currency(code: "PLN", name: "Polish Zloty", type: .fiat),
        Currency(code: "CZK", name: "Czech Koruna", type: .fiat),
        Currency(code: "HUF", name: "Hungarian Forint", type: .fiat),
        Currency(code: "RON", name: "Romanian Leu", type: .fiat),
        Currency(code: "BGN", name: "Bulgarian Lev", type: .fiat),
        Currency(code: "HRK", name: "Croatian Kuna", type: .fiat),
        Currency(code: "RSD", name: "Serbian Dinar", type: .fiat),
        Currency(code: "BAM", name: "Bosnia-Herzegovina Convertible Mark", type: .fiat),
        Currency(code: "MKD", name: "Macedonian Denar", type: .fiat),
        Currency(code: "ALL", name: "Albanian Lek", type: .fiat),
        Currency(code: "MDL", name: "Moldovan Leu", type: .fiat),
        Currency(code: "ISK", name: "Icelandic Krona", type: .fiat),
        
        // Latin American currencies
        Currency(code: "BRL", name: "Brazilian Real", type: .fiat),
        Currency(code: "MXN", name: "Mexican Peso", type: .fiat),
        Currency(code: "ARS", name: "Argentine Peso", type: .fiat),
        Currency(code: "CLP", name: "Chilean Peso", type: .fiat),
        Currency(code: "COP", name: "Colombian Peso", type: .fiat),
        Currency(code: "PEN", name: "Peruvian Sol", type: .fiat),
        Currency(code: "UYU", name: "Uruguayan Peso", type: .fiat),
        Currency(code: "PYG", name: "Paraguayan Guarani", type: .fiat),
        Currency(code: "BOB", name: "Bolivian Boliviano", type: .fiat),
        Currency(code: "VES", name: "Venezuelan Bolívar", type: .fiat),
        
        // Other currencies
        Currency(code: "IRR", name: "Iranian Rial", type: .fiat),
        Currency(code: "IQD", name: "Iraqi Dinar", type: .fiat),
        Currency(code: "AFN", name: "Afghan Afghani", type: .fiat),
        Currency(code: "SYP", name: "Syrian Pound", type: .fiat),
        Currency(code: "LBP", name: "Lebanese Pound", type: .fiat),
        Currency(code: "YER", name: "Yemeni Rial", type: .fiat),
        
        // Caribbean and Pacific
        Currency(code: "JMD", name: "Jamaican Dollar", type: .fiat),
        Currency(code: "BBD", name: "Barbadian Dollar", type: .fiat),
        Currency(code: "BSD", name: "Bahamian Dollar", type: .fiat),
        Currency(code: "XCD", name: "East Caribbean Dollar", type: .fiat),
        Currency(code: "TTD", name: "Trinidad and Tobago Dollar", type: .fiat),
        Currency(code: "FJD", name: "Fijian Dollar", type: .fiat),
        Currency(code: "TOP", name: "Tongan Paʻanga", type: .fiat),
        Currency(code: "WST", name: "Samoan Tala", type: .fiat),
        Currency(code: "VUV", name: "Vanuatu Vatu", type: .fiat),
        Currency(code: "PGK", name: "Papua New Guinean Kina", type: .fiat),
        
        // African currencies
        Currency(code: "ETB", name: "Ethiopian Birr", type: .fiat),
        Currency(code: "UGX", name: "Ugandan Shilling", type: .fiat),
        Currency(code: "TZS", name: "Tanzanian Shilling", type: .fiat),
        Currency(code: "RWF", name: "Rwandan Franc", type: .fiat),
        Currency(code: "BIF", name: "Burundian Franc", type: .fiat),
        Currency(code: "DJF", name: "Djiboutian Franc", type: .fiat),
        Currency(code: "SOS", name: "Somali Shilling", type: .fiat),
        Currency(code: "ERN", name: "Eritrean Nakfa", type: .fiat),
        Currency(code: "SDG", name: "Sudanese Pound", type: .fiat),
        Currency(code: "SSP", name: "South Sudanese Pound", type: .fiat),
        Currency(code: "CDF", name: "Congolese Franc", type: .fiat),
        Currency(code: "XAF", name: "Central African CFA Franc", type: .fiat),
        Currency(code: "XOF", name: "West African CFA Franc", type: .fiat),
        Currency(code: "KMF", name: "Comorian Franc", type: .fiat),
        Currency(code: "SCR", name: "Seychellois Rupee", type: .fiat),
        Currency(code: "MUR", name: "Mauritian Rupee", type: .fiat),
        Currency(code: "MGA", name: "Malagasy Ariary", type: .fiat),
        Currency(code: "MZN", name: "Mozambican Metical", type: .fiat),
        Currency(code: "ZMW", name: "Zambian Kwacha", type: .fiat),
        Currency(code: "BWP", name: "Botswanan Pula", type: .fiat),
        Currency(code: "NAD", name: "Namibian Dollar", type: .fiat),
        Currency(code: "SZL", name: "Swazi Lilangeni", type: .fiat),
        Currency(code: "LSL", name: "Lesotho Loti", type: .fiat)
    ]
    
    static let cryptoCurrencies: [Currency] = [
        // Major cryptocurrencies
        Currency(code: "BTC", name: "Bitcoin", type: .crypto),
        Currency(code: "ETH", name: "Ethereum", type: .crypto),
        Currency(code: "BNB", name: "BNB", type: .crypto),
        Currency(code: "XRP", name: "XRP", type: .crypto),
        Currency(code: "ADA", name: "Cardano", type: .crypto),
        Currency(code: "DOGE", name: "Dogecoin", type: .crypto),
        Currency(code: "SOL", name: "Solana", type: .crypto),
        Currency(code: "DOT", name: "Polkadot", type: .crypto),
        Currency(code: "MATIC", name: "Polygon", type: .crypto),
        Currency(code: "LTC", name: "Litecoin", type: .crypto),
        Currency(code: "AVAX", name: "Avalanche", type: .crypto),
        Currency(code: "LINK", name: "Chainlink", type: .crypto),
        Currency(code: "UNI", name: "Uniswap", type: .crypto),
        Currency(code: "ATOM", name: "Cosmos", type: .crypto),
        Currency(code: "ICP", name: "Internet Computer", type: .crypto),
        
        // Additional popular cryptos
        Currency(code: "BCH", name: "Bitcoin Cash", type: .crypto),
        Currency(code: "XLM", name: "Stellar", type: .crypto),
        Currency(code: "VET", name: "VeChain", type: .crypto),
        Currency(code: "FIL", name: "Filecoin", type: .crypto),
        Currency(code: "TRX", name: "TRON", type: .crypto),
        Currency(code: "ETC", name: "Ethereum Classic", type: .crypto),
        Currency(code: "XMR", name: "Monero", type: .crypto),
        Currency(code: "ALGO", name: "Algorand", type: .crypto),
        Currency(code: "HBAR", name: "Hedera", type: .crypto),
        Currency(code: "NEAR", name: "NEAR Protocol", type: .crypto)
    ]
    
    static func getCurrencies(for type: Currency.CurrencyType) -> [Currency] {
        switch type {
        case .fiat:
            return fiatCurrencies.sorted { $0.code < $1.code }
        case .crypto:
            return cryptoCurrencies.sorted { $0.code < $1.code }
        }
    }
    
    static func findCurrency(by code: String) -> Currency? {
        let allCurrencies = fiatCurrencies + cryptoCurrencies
        return allCurrencies.first { $0.code == code }
    }
    
    static func searchCurrencies(query: String, type: Currency.CurrencyType? = nil) -> [Currency] {
        let currencies = type == nil ? (fiatCurrencies + cryptoCurrencies) : getCurrencies(for: type!)
        
        if query.isEmpty {
            return currencies
        }
        
        return currencies.filter { currency in
            currency.code.lowercased().contains(query.lowercased()) ||
            currency.name.lowercased().contains(query.lowercased())
        }
    }
}
