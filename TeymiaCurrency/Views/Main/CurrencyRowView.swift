import SwiftUI

struct CurrencyRowView: View {
    let currency: Currency
    @ObservedObject var currencyStore: CurrencyStore
    
    // ✅ Use shared focus state
    @FocusState.Binding var focusedCurrency: String?
    
    @State private var inputText: String = ""
    
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
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Text(currency.dynamicLocalizedName)
                    .font(.subheadline)
                    .fontDesign(.rounded)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            // Amount display/input
            ZStack {
                TextField("0", text: $inputText)
                    .keyboardType(.decimalPad)
                    .focused($focusedCurrency, equals: currency.code)
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
            // ✅ Simple focus transfer
            focusedCurrency = currency.code
        }
        // ✅ Watch for focus changes
        .onChange(of: focusedCurrency) { newFocusedCode in
            handleFocusChange(newFocusedCode)
        }
        .onChange(of: currencyStore.baseAmount) { _ in
            updateDisplayIfNotEditing()
        }
        .onChange(of: currencyStore.exchangeRates) { _ in
            updateDisplayIfNotEditing()
        }
        .onAppear {
            updateDisplayFromStore()
        }
    }
    
    private var isThisFieldFocused: Bool {
        focusedCurrency == currency.code
    }
    
    private var shouldShowLoading: Bool {
        currencyStore.isFirstLaunch &&
        currencyStore.isLoading &&
        currency.code != "USD"
    }
    
    // ✅ Handle focus changes cleanly
    private func handleFocusChange(_ newFocusedCode: String?) {
        if newFocusedCode == currency.code {
            // This field just got focus - start editing
            currencyStore.editingCurrency = currency.code
            inputText = ""
        } else if currencyStore.editingCurrency == currency.code {
            // This field lost focus - commit
            commitEdit()
        }
    }
    
    private func commitEdit() {
        if inputText.isEmpty || inputText == "0" {
            currencyStore.updateAmount(0, for: currency.code)
        } else {
            let cleanedInput = inputText
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ",", with: ".")
            
            if let amount = Double(cleanedInput), amount >= 0 {
                currencyStore.updateAmount(amount, for: currency.code)
            }
        }
        
        updateDisplayFromStore()
    }
    
    private func handleTextInput(_ newValue: String) {
        let withoutSpaces = newValue.replacingOccurrences(of: " ", with: "")
        let filtered = withoutSpaces.filter { $0.isNumber || $0 == "," }
        
        let commaCount = filtered.filter { $0 == "," }.count
        if commaCount > 1 { return }
        
        if filtered == "," {
            inputText = "0,"
            return
        }
        
        let forParsing = filtered.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(forParsing) else {
            if !filtered.isEmpty {
                inputText = filtered
            }
            return
        }
        
        let formattedText = formatInputValue(amount, hasDecimal: filtered.contains(","))
        
        if inputText != formattedText {
            inputText = formattedText
        }
        
        // ✅ Simple check
        if isThisFieldFocused && amount >= 0 {
            currencyStore.updateAmount(amount, for: currency.code)
        }
    }
    
    private func formatInputValue(_ amount: Double, hasDecimal: Bool) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","
        
        if hasDecimal {
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }
    
    private func updateDisplayIfNotEditing() {
        guard !isThisFieldFocused else { return }
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
        
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","
        
        if currency.type == .crypto {
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
