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
                    .foregroundStyle(.primary)
                
                Text(currency.dynamicLocalizedName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            // Amount display/input with loading state
            ZStack {
                TextField("0", text: $inputText)
                    .keyboardType(.decimalPad)
                    .focused($isFieldFocused)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .fontWeight(.medium)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .opacity(shouldShowLoading ? 0 : 1)
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
                        isFieldFocused = true
                    }
                
                // Show loading indicator
                if shouldShowLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            isFieldFocused = true
        }
        .onReceive(currencyStore.$baseAmount) { _ in
            updateIfNotEditing()
        }
        .onReceive(currencyStore.$exchangeRates) { _ in
            updateIfNotEditing()
        }
        .onReceive(currencyStore.$isFirstLaunch) { _ in
            updateIfNotEditing()
        }
        .onReceive(currencyStore.$isLoading) { _ in
            updateIfNotEditing()
        }
        .onAppear {
            updateDisplayFromStore()
        }
    }
    
    private var shouldShowLoading: Bool {
        return currencyStore.isFirstLaunch &&
               currencyStore.isLoading &&
               currency.code != "USD"
    }
    
    private func startEditing() {
        isEditing = true
        currencyStore.editingCurrency = currency.code
        inputText = ""
    }

    private func commitEdit() {
        isEditing = false
        
        if inputText.isEmpty || inputText == "0" {
            currencyStore.updateAmount(0, for: currency.code)
        } else if let amount = Double(inputText.replacingOccurrences(of: ",", with: ".")), amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
        
        currencyStore.editingCurrency = "USD"
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
        
        if isEditing &&
           currencyStore.editingCurrency == currency.code,
           let amount = Double(filtered.replacingOccurrences(of: ",", with: ".")),
           amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    private func updateIfNotEditing() {
        if !isEditing {
            updateDisplayFromStore()
        }
    }

    private func updateDisplayFromStore() {
        if !isEditing && !shouldShowLoading {
            let displayAmount = currencyStore.getDisplayAmount(for: currency.code)
            let newText = formatDisplayValue(displayAmount, for: currency)
            
            if inputText != newText {
                inputText = newText
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
            } else if amount >= 1 {
                formatter.maximumFractionDigits = 2
            } else if amount >= 0.01 {
                formatter.maximumFractionDigits = 4
            } else {
                formatter.maximumFractionDigits = 6
            }
        } else {
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            
            if amount >= 1000000 {
                formatter.maximumFractionDigits = 0
            } else if amount >= 1000 {
                formatter.maximumFractionDigits = 2
            } else if amount >= 1 {
                formatter.maximumFractionDigits = 2
            } else if amount >= 0.01 {
                formatter.maximumFractionDigits = 4
            } else {
                formatter.maximumFractionDigits = 6
            }
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
