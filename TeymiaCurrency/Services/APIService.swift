import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://api.exconvert.com"
    private let accessKey = "5fcb4a0d-1b6056bb-1f65f799-c1af40b2"
    
    // MARK: - Methods
    
    func fetchAllRates(baseCurrency: String = "USD", completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/fetchAll?access_key=\(accessKey)&from=\(baseCurrency)"
        performRequest(urlString: urlString, completion: completion)
    }
    
    func fetchMultipleRates(from baseCurrency: String, to targetCurrencies: [String], completion: @escaping (Result<ExchangeRateResponse, Error>) -> Void) {
        let currenciesString = targetCurrencies.joined(separator: ",")
        let urlString = "\(baseURL)/fetchMulti?access_key=\(accessKey)&from=\(baseCurrency)&to=\(currenciesString)"
        performRequest(urlString: urlString, completion: completion)
    }
    
    func convertAmount(amount: Double, from: String, to: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = "\(baseURL)/convert?access_key=\(accessKey)&from=\(from)&to=\(to)&amount=\(amount)"
        
        performRequest(urlString: urlString) { (result: Result<ExchangeRateResponse, Error>) in
            switch result {
            case .success(let response):
                if let rate = response.rates[to] {
                    completion(.success(rate * amount))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            case .failure(let error):
                completion(.failure(error))
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
            
            // debug
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
    
    // MARK: - Mock
    func getMockRates() -> ExchangeRateResponse {
        return ExchangeRateResponse(
            base: "USD",
            date: "2025-08-25",
            rates: [
                "USD": 1.0,
                "EUR": 0.85,
                "KZT": 450.0,
                "RUB": 75.0,
                "BTC": 0.00002,
                "ETH": 0.0006,
                "GBP": 0.78,
                "JPY": 110.0
            ]
        )
    }
}
