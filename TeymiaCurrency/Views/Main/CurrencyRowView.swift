import SwiftUI

struct CurrencyRowView: View {
    let currency: Currency
    @ObservedObject var currencyStore: CurrencyStore
    
    @State private var inputText: String = ""
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency flag/icon
            Image(currency.code)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                )
            
            // Currency info
            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Text(currency.dynamicLocalizedName)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
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
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
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
        .onChange(of: currencyStore.baseAmount) { _ in
            updateDisplayIfNeeded()
        }
        .onChange(of: currencyStore.exchangeRates) { _ in
            updateDisplayIfNeeded()
        }
        .onChange(of: currencyStore.editingCurrency) { _ in
            updateDisplayIfNeeded()
        }
        .onAppear {
            updateDisplayFromStore()
        }
    }
    
    private var isThisFieldBeingEdited: Bool {
        return isFieldFocused && currencyStore.editingCurrency == currency.code
    }
    
    private var shouldShowLoading: Bool {
        return currencyStore.isFirstLaunch &&
               currencyStore.isLoading &&
               currency.code != "USD"
    }
    
    private func startEditing() {
        currencyStore.editingCurrency = currency.code
        inputText = ""
    }

    private func commitEdit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if inputText.isEmpty || inputText == "0" {
                currencyStore.updateAmount(0, for: currency.code)
            } else {
                // Remove spaces before parsing
                let cleanedInput = inputText.replacingOccurrences(of: " ", with: "")
                if let amount = Double(cleanedInput.replacingOccurrences(of: ",", with: ".")), amount >= 0 {
                    currencyStore.updateAmount(amount, for: currency.code)
                }
            }
            
            if currencyStore.editingCurrency == currency.code {
                currencyStore.editingCurrency = "USD"
            }
        }
    }

    private func handleTextInput(_ newValue: String) {
        // Remove all spaces first to get clean input
        let withoutSpaces = newValue.replacingOccurrences(of: " ", with: "")
        
        // Filter invalid characters (allow only digits, dot, comma)
        let filtered = withoutSpaces.filter { $0.isNumber || $0 == "." || $0 == "," }
        
        // Auto-fix leading dot
        if filtered == "." || filtered == "," {
            inputText = "0."
            return
        }
        
        // Parse the number
        guard let amount = Double(filtered.replacingOccurrences(of: ",", with: ".")) else {
            if !filtered.isEmpty {
                inputText = filtered
            }
            return
        }
        
        // Format with spaces in real-time
        let formattedText = formatInputValue(amount)
        
        // Update the display
        if inputText != formattedText {
            inputText = formattedText
        }
        
        // Update amount in real-time only if THIS field is being edited
        if isThisFieldBeingEdited && amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    // ✅ NEW: Format input value in real-time with spaces
    private func formatInputValue(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 6
        
        return formatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }
    
    private func updateDisplayIfNeeded() {
        guard !isThisFieldBeingEdited else { return }
        guard !shouldShowLoading else { return }
        
        updateDisplayFromStore()
    }

    private func updateDisplayFromStore() {
        let displayAmount = currencyStore.getDisplayAmount(for: currency.code)
        let newText = formatDisplayValue(displayAmount, for: currency)
        
        if inputText != newText {
            inputText = newText
        }
    }
    
    private func formatDisplayValue(_ amount: Double, for currency: Currency) -> String {
        let formatter = NumberFormatter()
        
        if currency.type == .crypto {
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
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
            formatter.groupingSeparator = " "
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
