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
    
    // MARK: - Crypto Currency Mapping
    
    private func cryptoCodeToCoinGeckoId(_ code: String) -> String? {
        let mapping: [String: String] = [
            "AAVE": "aave",
            "ADA": "cardano",
            "ALGO": "algorand",
            "APT": "aptos",
            "ARB": "arbitrum",
            "ATOM": "cosmos",
            "AVAX": "avalanche-2",
            "AXS": "axie-infinity",
            "BCH": "bitcoin-cash",
            "BGB": "bitget-token",
            "BNB": "binancecoin",
            "BTC": "bitcoin",
            "BUSD": "binance-usd",
            "CFX": "conflux-token",
            "CRO": "crypto-com-chain",
            "DAI": "dai",
            "DOGE": "dogecoin",
            "DOT": "polkadot",
            "EGLD": "elrond-erd-2",
            "ETC": "ethereum-classic",
            "ETH": "ethereum",
            "FIL": "filecoin",
            "FLR": "flare-networks",
            "GRT": "the-graph",
            "HBAR": "hedera-hashgraph",
            "ICP": "internet-computer",
            "INJ": "injective-protocol",
            "JLP": "jupiter-exchange-solana", // или другой Jupiter token ID
            "KAS": "kaspa",
            "LDO": "lido-dao",
            "LEO": "leo-token",
            "LINK": "chainlink",
            "LTC": "litecoin",
            "LUNC": "terra-luna-classic",
            "METH": "mantle-staked-ether", // или другой METH ID
            "NEAR": "near",
            "OP": "optimism",
            "POL": "matic-network",
            "PYTH": "pyth-network",
            "QNT": "quant-network",
            "RENDER": "render-token",
            "SEI": "sei-network",
            "SHIB": "shiba-inu",
            "SOL": "solana",
            "STETH": "staked-ether",
            "STX": "blockstack",
            "SUI": "sui",
            "TAO": "bittensor",
            "THETA": "theta-token",
            "TIA": "celestia",
            "TON": "the-open-network",
            "TRX": "tron",
            "UNI": "uniswap",
            "USDC": "usd-coin",
            "USDT": "tether",
            "VET": "vechain",
            "WBT": "whitebit", // или другой WBT ID
            "WBTC": "wrapped-bitcoin",
            "XLM": "stellar",
            "XMR": "monero",
            "XRP": "ripple",
            "XTZ": "tezos",
            "ZEC": "zcash"
        ]
        
        return mapping[code]
    }
    
    private func coinGeckoIdToCryptoCode(_ id: String) -> String? {
        let mapping: [String: String] = [
            "aave": "AAVE",
            "cardano": "ADA",
            "algorand": "ALGO",
            "aptos": "APT",
            "arbitrum": "ARB",
            "cosmos": "ATOM",
            "avalanche-2": "AVAX",
            "axie-infinity": "AXS",
            "bitcoin-cash": "BCH",
            "bitget-token": "BGB",
            "binancecoin": "BNB",
            "bitcoin": "BTC",
            "binance-usd": "BUSD",
            "conflux-token": "CFX",
            "crypto-com-chain": "CRO",
            "dai": "DAI",
            "dogecoin": "DOGE",
            "polkadot": "DOT",
            "elrond-erd-2": "EGLD",
            "ethereum-classic": "ETC",
            "ethereum": "ETH",
            "filecoin": "FIL",
            "flare-networks": "FLR",
            "the-graph": "GRT",
            "hedera-hashgraph": "HBAR",
            "internet-computer": "ICP",
            "injective-protocol": "INJ",
            "jupiter-exchange-solana": "JLP",
            "kaspa": "KAS",
            "lido-dao": "LDO",
            "leo-token": "LEO",
            "chainlink": "LINK",
            "litecoin": "LTC",
            "terra-luna-classic": "LUNC",
            "mantle-staked-ether": "METH",
            "near": "NEAR",
            "optimism": "OP",
            "matic-network": "POL",
            "pyth-network": "PYTH",
            "quant-network": "QNT",
            "render-token": "RENDER",
            "sei-network": "SEI",
            "shiba-inu": "SHIB",
            "solana": "SOL",
            "staked-ether": "STETH",
            "blockstack": "STX",
            "sui": "SUI",
            "bittensor": "TAO",
            "theta-token": "THETA",
            "celestia": "TIA",
            "the-open-network": "TON",
            "tron": "TRX",
            "uniswap": "UNI",
            "usd-coin": "USDC",
            "tether": "USDT",
            "vechain": "VET",
            "whitebit": "WBT",
            "wrapped-bitcoin": "WBTC",
            "stellar": "XLM",
            "monero": "XMR",
            "ripple": "XRP",
            "tezos": "XTZ",
            "zcash": "ZEC"
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
