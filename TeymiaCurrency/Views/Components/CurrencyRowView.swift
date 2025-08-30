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
            if isEditing {
                TextField("0", text: $inputText)
                    .keyboardType(.decimalPad)
                    .focused($isFieldFocused)
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .onSubmit {
                        commitEdit()
                    }
                    .onChange(of: inputText) { newValue in
                        handleTextInput(newValue)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFieldFocused = true
                        }
                    }
            } else {
                Text(formattedDisplayAmount)
                    .font(.title)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                startEditing()
            }
        }
        .onChange(of: isFieldFocused) { focused in
            if !focused && isEditing {
                commitEdit()
            }
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
        isEditing = true
        inputText = ""
        currencyStore.editingCurrency = currency.code
    }
    
    private func commitEdit() {
        isEditing = false
        currencyStore.editingCurrency = "USD"
        
        if inputText.isEmpty || inputText == "0" {
            currencyStore.updateAmount(0, for: currency.code)
        } else if let amount = Double(inputText.replacingOccurrences(of: ",", with: ".")), amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
        
        updateDisplayFromStore()
    }
    
    private func handleTextInput(_ newValue: String) {
        let filtered = newValue.filter { $0.isNumber || $0 == "." || $0 == "," }
        if filtered != newValue {
            inputText = filtered
            return
        }
        
        if filtered == "." {
            inputText = "0."
            return
        }
        
        if let amount = Double(filtered.replacingOccurrences(of: ",", with: ".")),
           amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    private func updateIfNotEditing() {
        if !isEditing && currencyStore.editingCurrency != currency.code {
            updateDisplayFromStore()
        }
    }
    
    private func updateDisplayFromStore() {
        let displayAmount = currencyStore.getDisplayAmount(for: currency.code)
        inputText = formatInputValue(displayAmount)
    }
    
    private var formattedDisplayAmount: String {
        let amount = currencyStore.getDisplayAmount(for: currency.code)
        return formatDisplayValue(amount, for: currency)
    }
    
    // MARK: - Formatting Methods
    
    private func formatInputValue(_ amount: Double) -> String {
        if amount == 0 {
            return "0"
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
        
        return formatter.string(from: NSNumber(value: amount)) ?? formatInputValue(amount)
    }
}

// MARK: - UIView Extension

extension UIView {
    var allSubViews: [UIView] {
        var subs = self.subviews
        for subview in subviews {
            subs.append(contentsOf: subview.allSubViews)
        }
        return subs
    }
}
