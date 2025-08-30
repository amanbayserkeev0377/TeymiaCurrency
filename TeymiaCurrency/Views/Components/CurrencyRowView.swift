import SwiftUI

struct CurrencyRowView: View {
    let currency: Currency
    @ObservedObject var currencyStore: CurrencyStore
    
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency flag/icon
            Image(currency.code)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                )
            
            // Currency info
            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(currency.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Amount display/input
            TextField("0", text: $inputText)
                .keyboardType(.decimalPad)
                .focused($isFieldFocused)
                .multilineTextAlignment(.trailing)
                .font(.title)
                .fontWeight(.medium)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .onChange(of: inputText) { newValue in
                    handleTextInput(newValue)
                }
                .onChange(of: isFieldFocused) { focused in
                    if focused {
                        startEditing()
                    } else {
                        commitEdit()
                    }
                }
                .onTapGesture {
                    // Force focus on tap
                    isFieldFocused = true
                }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            // Make entire row tappable
            isFieldFocused = true
        }
        .onReceive(currencyStore.$baseAmount) { _ in
            updateIfNotEditing()
        }
        .onReceive(currencyStore.$exchangeRates) { _ in
            updateIfNotEditing()
        }
        .onAppear {
            updateDisplayFromStore()
        }
    }
    
    // MARK: - Private Methods
    
    private func startEditing() {
        print("🔍 [DEBUG] Start editing \(currency.code)")
        isEditing = true
        currencyStore.editingCurrency = currency.code
        inputText = ""
    }
    
    private func commitEdit() {
        print("🔍 [DEBUG] Commit edit \(currency.code): '\(inputText)'")
        isEditing = false
        currencyStore.editingCurrency = "USD"
        
        // Parse and update amount
        if inputText.isEmpty || inputText == "0" {
            currencyStore.updateAmount(0, for: currency.code)
        } else if let amount = Double(inputText.replacingOccurrences(of: ",", with: ".")), amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    private func handleTextInput(_ newValue: String) {
        // Filter invalid characters
        let filtered = newValue.filter { $0.isNumber || $0 == "." || $0 == "," }
        if filtered != newValue {
            inputText = filtered
            return
        }
        
        // Handle decimal point
        if filtered == "." {
            inputText = "0."
            return
        }
        
        // Update amount in real-time if editing
        if isEditing, let amount = Double(filtered.replacingOccurrences(of: ",", with: ".")), amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    private func updateIfNotEditing() {
        if !isEditing {
            updateDisplayFromStore()
        }
    }
    
    private func updateDisplayFromStore() {
        if !isEditing {
            let displayAmount = currencyStore.getDisplayAmount(for: currency.code)
            inputText = formatDisplayValue(displayAmount, for: currency)
        }
    }
    
    // MARK: - Formatting Methods
    
    private func formatInputValue(_ amount: Double) -> String {
        if amount == 0 {
            return ""
        }
        
        if currency.type == .crypto {
            if amount >= 1000 {
                return String(format: "%.0f", amount)
            } else if amount >= 1 {
                return String(format: "%.2f", amount)
            } else if amount >= 0.01 {
                return String(format: "%.4f", amount)
            } else {
                return String(format: "%.6f", amount)
            }
        } else {
            if amount >= 1000000 {
                return String(format: "%.0f", amount)
            } else if amount >= 1000 {
                return String(format: "%.0f", amount)
            } else if amount >= 1 {
                return String(format: "%.2f", amount)
            } else if amount >= 0.01 {
                return String(format: "%.4f", amount)
            } else {
                return String(format: "%.6f", amount)
            }
        }
    }
    
    private func formatDisplayValue(_ amount: Double, for currency: Currency) -> String {
        let formatter = NumberFormatter()
        
        if currency.type == .crypto {
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            
            if amount >= 1000 {
                formatter.maximumFractionDigits = 0
                formatter.minimumFractionDigits = 0
            } else if amount >= 1 {
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
            } else if amount >= 0.01 {
                formatter.maximumFractionDigits = 4
                formatter.minimumFractionDigits = 0
            } else {
                formatter.maximumFractionDigits = 6
                formatter.minimumFractionDigits = 0
            }
        } else {
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            
            if amount >= 1000000 {
                formatter.maximumFractionDigits = 0
                formatter.minimumFractionDigits = 0
            } else if amount >= 1000 {
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
            } else if amount >= 1 {
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
            } else if amount >= 0.01 {
                formatter.maximumFractionDigits = 4
                formatter.minimumFractionDigits = 0
            } else {
                formatter.maximumFractionDigits = 6
                formatter.minimumFractionDigits = 0
            }
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
