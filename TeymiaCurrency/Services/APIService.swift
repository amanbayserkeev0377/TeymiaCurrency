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
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchMultipleFiatRates(from baseCurrency: String, to targetCurrencies: [String], completion: @escaping (Result<[String: Double], Error>) -> Void) {
        fetchFiatRates(baseCurrency: baseCurrency) { result in
            switch result {
            case .success(let response):
                let filteredRates = response.rates.filter { targetCurrencies.contains($0.key) }
                completion(.success(filteredRates))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Crypto Currency Methods (CoinGecko API)
    
    func fetchCryptoRates(targetCurrencies: [String], vsCurrency: String = "usd", completion: @escaping (Result<[String: Double], Error>) -> Void) {
        // Convert currency codes to CoinGecko IDs
        let coinIds = targetCurrencies.compactMap { cryptoCodeToCoinGeckoId($0) }
        let idsString = coinIds.joined(separator: ",")
        
        let urlString = "\(cryptoBaseURL)/simple/price?ids=\(idsString)&vs_currencies=\(vsCurrency)"
        
        performRequest(urlString: urlString) { (result: Result<CryptoExchangeResponse, Error>) in
            switch result {
            case .success(let response):
                // Convert back from CoinGecko format to our format
                var rates: [String: Double] = [:]
                
                for (coinId, priceData) in response {
                    if let cryptoCode = self.coinGeckoIdToCryptoCode(coinId),
                       let price = priceData[vsCurrency] {
                        rates[cryptoCode] = price
                    }
                }
                
                completion(.success(rates))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Combined Method for CurrencyService
    
    func fetchRatesForCurrencies(_ currencies: [Currency], baseCurrency: String = "USD", completion: @escaping (Result<[String: Double], Error>) -> Void) {
        let fiatCurrencies = currencies.filter { $0.type == .fiat }.map { $0.code }
        let cryptoCurrencies = currencies.filter { $0.type == .crypto }.map { $0.code }
        
        let group = DispatchGroup()
        var combinedRates: [String: Double] = [:]
        var errors: [Error] = []
        
        // Fetch fiat rates
        if !fiatCurrencies.isEmpty {
            group.enter()
            fetchMultipleFiatRates(from: baseCurrency, to: fiatCurrencies) { result in
                defer { group.leave() }
                switch result {
                case .success(let rates):
                    combinedRates.merge(rates) { _, new in new }
                case .failure(let error):
                    errors.append(error)
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
                case .failure(let error):
                    errors.append(error)
                }
            }
        }
        
        group.notify(queue: .main) {
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
            completion(.failure(URLError(.badURL)))
            return
        }
        
        print("Requesting: \(urlString)") // for debug
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            // Debug response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Crypto Currency Mapping
    
    private func cryptoCodeToCoinGeckoId(_ code: String) -> String? {
        let mapping: [String: String] = [
            "BTC": "bitcoin",
            "ETH": "ethereum",
            "BNB": "binancecoin",
            "ADA": "cardano",
            "XRP": "ripple",
            "DOGE": "dogecoin",
            "DOT": "polkadot",
            "SOL": "solana",
            "MATIC": "matic-network",
            "LINK": "chainlink",
            "LTC": "litecoin",
            "AVAX": "avalanche-2",
            "UNI": "uniswap",
            "ATOM": "cosmos",
            "ICP": "internet-computer"
        ]
        return mapping[code]
    }
    
    private func coinGeckoIdToCryptoCode(_ id: String) -> String? {
        let reverseMapping: [String: String] = [
            "bitcoin": "BTC",
            "ethereum": "ETH",
            "binancecoin": "BNB",
            "cardano": "ADA",
            "ripple": "XRP",
            "dogecoin": "DOGE",
            "polkadot": "DOT",
            "solana": "SOL",
            "matic-network": "MATIC",
            "chainlink": "LINK",
            "litecoin": "LTC",
            "avalanche-2": "AVAX",
            "uniswap": "UNI",
            "cosmos": "ATOM",
            "internet-computer": "ICP"
        ]
        return reverseMapping[id]
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
