import SwiftUI

struct CurrencyRowView: View {
    let currency: Currency
    @ObservedObject var currencyStore: CurrencyStore
    
    @State private var inputAmount: String = "1"
    @State private var isInputMode: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency flag/icon
            Image(currency.code)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                )
            
            // Currency info
            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(currency.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Input field and converted amount
            if isInputMode {
                // Text input mode - for entering custom amounts
                TextField("", text: $inputAmount)
                    .keyboardType(.decimalPad)
                    .focused($isInputFocused)
                    .multilineTextAlignment(.trailing)
                    .font(.title2)
                    .fontWeight(.medium)
                    .frame(width: 100)
            } else {
                // Display mode - shows current rate or converted amount
                if currencyStore.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 100)
                } else {
                    Button(action: {
                        // Set current displayed value before editing
                        let displayValue = getDisplayAmount()
                        inputAmount = displayValue
                        isInputMode = true
                        isInputFocused = true
                    }) {
                        Text(getDisplayAmount())
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .frame(width: 100, alignment: .trailing)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
        .onChange(of: isInputFocused) { focused in
            if !focused {
                isInputMode = false
            }
        }
    }
    
    private func getDisplayAmount() -> String {
        guard let amount = Double(inputAmount), amount > 0 else {
            return formatRate(currencyStore.getExchangeRate(for: currency), for: currency)
        }
        
        let rate = currencyStore.getExchangeRate(for: currency)
        let convertedAmount = amount * rate
        
        return formatAmount(convertedAmount, for: currency)
    }
    
    private func formatAmount(_ amount: Double, for currency: Currency) -> String {
        // Just show numbers without currency symbols
        if currency.type == .crypto {
            if amount >= 1000 {
                return String(format: "%.0f", amount)
            } else if amount >= 1 {
                return String(format: "%.2f", amount)
            } else {
                return String(format: "%.4f", amount)
            }
        } else {
            // For fiat - just numbers
            if amount < 0.01 {
                return String(format: "%.6f", amount)
            } else if amount < 1.0 {
                return String(format: "%.4f", amount)
            } else if amount < 10.0 {
                return String(format: "%.3f", amount)
            } else {
                return String(format: "%.2f", amount)
            }
        }
    }
    
    private func formatRate(_ rate: Double, for currency: Currency) -> String {
        // Just show numbers without currency symbols
        if currency.type == .crypto {
            if rate >= 1000 {
                return String(format: "%.0f", rate)
            } else if rate >= 1 {
                return String(format: "%.2f", rate)
            } else {
                return String(format: "%.4f", rate)
            }
        } else {
            // For fiat show rate relative to USD - just numbers
            if currency.code == "USD" {
                return "1.00"
            } else {
                if rate < 0.01 {
                    return String(format: "%.6f", rate)
                } else if rate < 1.0 {
                    return String(format: "%.4f", rate)
                } else if rate < 10.0 {
                    return String(format: "%.3f", rate)
                } else {
                    return String(format: "%.2f", rate)
                }
            }
        }
    }
}
