import Foundation

struct Currency: Codable, Hashable {
    let code: String
    let name: String
    let type: CurrencyType
    
    enum CurrencyType: String, Codable {
        case fiat
        case crypto
    }
    
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
