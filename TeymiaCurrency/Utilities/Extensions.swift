import SwiftUI
import Foundation

// MARK: - Double Extensions

extension Double {
    func formatted(for currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.maximumFractionDigits = currency.type == .crypto ? 6 : 2
        formatter.minimumFractionDigits = currency.type == .crypto ? 2 : 2
        
        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.2f", self)
    }
}

// MARK: - Date Extensions

extension Date {
    func isOlderThan(minutes: Int) -> Bool {
        let timeInterval = TimeInterval(minutes * 60)
        return Date().timeIntervalSince(self) > timeInterval
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            set(data, forKey: key)
        } catch {
            print("Error encoding \(key): \(error)")
        }
    }
    
    func getCodable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Error decoding \(key): \(error)")
            return nil
        }
    }
}
