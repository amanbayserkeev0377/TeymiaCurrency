import Foundation

class APIService {
    static let shared = APIService()
    
    // ExchangeRate API for fiat currencies
    private let fiatBaseURL = "https://api.exchangerate-api.com/v4"
    
    // CoinGecko API for crypto currencies
    private let cryptoBaseURL = "https://api.coingecko.com/api/v3"
    
    private init() {}
    
    // MARK: - Fiat Currency Methods (ExchangeRate API)
    
    func fetchFiatRates(baseCurrency: String = "USD", completion: @escaping (Result<FiatExchangeResponse, Error>) -> Void) {
        let urlString = "\(fiatBaseURL)/latest/\(baseCurrency)"
        print("🌐 [FIAT API] Requesting: \(urlString)")
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchMultipleFiatRates(from baseCurrency: String, to targetCurrencies: [String], completion: @escaping (Result<[String: Double], Error>) -> Void) {
        print("💱 [FIAT] Fetching rates for: \(targetCurrencies)")
        fetchFiatRates(baseCurrency: baseCurrency) { result in
            switch result {
            case .success(let response):
                print("✅ [FIAT] Got \(response.rates.count) rates")
                let filteredRates = response.rates.filter { targetCurrencies.contains($0.key) }
                print("📝 [FIAT] Filtered to \(filteredRates.count) currencies: \(Array(filteredRates.keys))")
                completion(.success(filteredRates))
            case .failure(let error):
                print("❌ [FIAT] Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Crypto Currency Methods (CoinGecko API)
    
    func fetchCryptoRates(targetCurrencies: [String], vsCurrency: String = "usd", completion: @escaping (Result<[String: Double], Error>) -> Void) {
        print("🔸 [CRYPTO] Fetching rates for: \(targetCurrencies)")
        
        // Convert currency codes to CoinGecko IDs
        let coinIds = targetCurrencies.compactMap { cryptoCodeToCoinGeckoId($0) }
        print("🔸 [CRYPTO] Mapped to CoinGecko IDs: \(coinIds)")
        
        let idsString = coinIds.joined(separator: ",")
        let urlString = "\(cryptoBaseURL)/simple/price?ids=\(idsString)&vs_currencies=\(vsCurrency)"
        print("🌐 [CRYPTO API] Requesting: \(urlString)")
        
        performRequest(urlString: urlString) { (result: Result<CryptoExchangeResponse, Error>) in
            switch result {
            case .success(let response):
                print("✅ [CRYPTO] Got response for \(response.count) coins")
                
                // Convert back from CoinGecko format to our format
                var rates: [String: Double] = [:]
                
                for (coinId, priceData) in response {
                    if let cryptoCode = self.coinGeckoIdToCryptoCode(coinId),
                       let price = priceData[vsCurrency] {
                        rates[cryptoCode] = price
                        print("💰 [CRYPTO] \(cryptoCode): $\(price)")
                    }
                }
                
                print("📝 [CRYPTO] Final rates: \(rates.keys)")
                completion(.success(rates))
            case .failure(let error):
                print("❌ [CRYPTO] Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Combined Method for CurrencyService
    
    func fetchRatesForCurrencies(_ currencies: [Currency], baseCurrency: String = "USD", completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let fiatCurrencies = currencies.filter { $0.type == .fiat }.map { $0.code }
        let cryptoCurrencies = currencies.filter { $0.type == .crypto }.map { $0.code }
        
        print("🚀 [COMBINED] Starting fetch for \(fiatCurrencies.count) fiat + \(cryptoCurrencies.count) crypto")
        
        let group = DispatchGroup()
        var combinedRates: [String: Double] = [:]
        var errors: [Error] = []
        
        // Always add base currency rate (1.0 for USD)
        if fiatCurrencies.contains(baseCurrency) || cryptoCurrencies.contains(baseCurrency) {
            combinedRates[baseCurrency] = 1.0
        }
        
        // Fetch fiat rates
        if !fiatCurrencies.isEmpty {
            group.enter()
            fetchMultipleFiatRates(from: baseCurrency, to: fiatCurrencies) { result in
                defer { group.leave() }
                switch result {
                case .success(let rates):
                    combinedRates.merge(rates) { _, new in new }
                    print("✅ [COMBINED] Added fiat rates: \(rates.count)")
                case .failure(let error):
                    errors.append(error)
                    print("❌ [COMBINED] Fiat error: \(error)")
                }
            }
        }
        
        // Fetch crypto rates
        if !cryptoCurrencies.isEmpty {
            group.enter()
            fetchCryptoRates(targetCurrencies: cryptoCurrencies) { result in
                defer { group.leave() }
                switch result {
                case .success(let rates):
                    combinedRates.merge(rates) { _, new in new }
                    print("✅ [COMBINED] Added crypto rates: \(rates.count)")
                case .failure(let error):
                    errors.append(error)
                    print("❌ [COMBINED] Crypto error: \(error)")
                }
            }
        }
        
        group.notify(queue: .main) {
            print("🏁 [COMBINED] Finished! Total rates: \(combinedRates.count), Errors: \(errors.count)")
            
            if !errors.isEmpty && combinedRates.isEmpty {
                completion(.failure(errors.first!))
            } else {
                completion(.success(combinedRates))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func performRequest<T: Codable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let error = NSError(domain: "APIService", code: httpResponse.statusCode,
                                      userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
                    completion(.failure(error))
                    return
                }
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("📊 Data size: \(data.count) bytes")
            
            // Debug response for first few requests
            if Constants.Debug.enableAPILogging {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let preview = jsonString.count > 200 ? String(jsonString.prefix(200)) + "..." : jsonString
                    print("📄 Response preview: \(preview)")
                }
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded response")
                completion(.success(response))
            } catch {
                print("❌ Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw response: \(jsonString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Crypto Currency Mapping (Expanded)
    
    private func cryptoCodeToCoinGeckoId(_ code: String) -> String? {
        let mapping: [String: String] = [
            // Major cryptocurrencies
            "BTC": "bitcoin",
            "ETH": "ethereum",
            "BNB": "binancecoin",
            "ADA": "cardano",
            "XRP": "ripple",
            "DOGE": "dogecoin",
            "DOT": "polkadot",
            "SOL": "solana",
            "MATIC": "matic-network", // Note: POL is new Polygon
            "POL": "matic-network",
            "LINK": "chainlink",
            "LTC": "litecoin",
            "AVAX": "avalanche-2",
            "UNI": "uniswap",
            "ATOM": "cosmos",
            "ICP": "internet-computer",
            
            // Additional cryptos from your assets
            "AAVE": "aave",
            "ALGO": "algorand",
            "APT": "aptos",
            "ARB": "arbitrum",
            "AXS": "axie-infinity",
            "BCH": "bitcoin-cash",
            "BUSD": "binance-usd",
            "DAI": "dai",
            "ETC": "ethereum-classic",
            "FIL": "filecoin",
            "HBAR": "hedera-hashgraph",
            "NEAR": "near",
            "OP": "optimism",
            "SHIB": "shiba-inu",
            "STX": "blockstack",
            "SUI": "sui",
            "TON": "the-open-network",
            "TRX": "tron",
            "USDC": "usd-coin",
            "USDT": "tether",
            "VET": "vechain",
            "XLM": "stellar",
            "XMR": "monero",
            "XTZ": "tezos"
        ]
        
        return mapping[code]
    }
    
    private func coinGeckoIdToCryptoCode(_ id: String) -> String? {
        // Reverse mapping - just flip the dictionary
        let mapping = [
            "bitcoin": "BTC",
            "ethereum": "ETH",
            "binancecoin": "BNB",
            "cardano": "ADA",
            "ripple": "XRP",
            "dogecoin": "DOGE",
            "polkadot": "DOT",
            "solana": "SOL",
            "matic-network": "POL", // Using POL as current Polygon token
            "chainlink": "LINK",
            "litecoin": "LTC",
            "avalanche-2": "AVAX",
            "uniswap": "UNI",
            "cosmos": "ATOM",
            "internet-computer": "ICP",
            "aave": "AAVE",
            "algorand": "ALGO",
            "aptos": "APT",
            "arbitrum": "ARB",
            "axie-infinity": "AXS",
            "bitcoin-cash": "BCH",
            "binance-usd": "BUSD",
            "dai": "DAI",
            "ethereum-classic": "ETC",
            "filecoin": "FIL",
            "hedera-hashgraph": "HBAR",
            "near": "NEAR",
            "optimism": "OP",
            "shiba-inu": "SHIB",
            "blockstack": "STX",
            "sui": "SUI",
            "the-open-network": "TON",
            "tron": "TRX",
            "usd-coin": "USDC",
            "tether": "USDT",
            "vechain": "VET",
            "stellar": "XLM",
            "monero": "XMR",
            "tezos": "XTZ"
        ]
        
        return mapping[id]
    }
}

// MARK: - Response Models

struct FiatExchangeResponse: Codable {
    let base: String
    let date: String
    let rates: [String: Double]
}

// CoinGecko returns nested structure like {"bitcoin": {"usd": 45000}}
typealias CryptoExchangeResponse = [String: [String: Double]]
