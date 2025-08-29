import SwiftUI

struct CurrencySelectionView: View {
    @ObservedObject var currencyStore: CurrencyStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: Currency.CurrencyType = .fiat
    @State private var searchText = ""
    @State private var showingSearchResults = false
    
    private var availableCurrencies: [Currency] {
        let currencies = currencyStore.getAvailableCurrencies(for: selectedType)
        
        if searchText.isEmpty {
            return currencies
        } else {
            return CurrencyData.searchCurrencies(query: searchText, type: selectedType)
                .filter { currency in
                    !currencyStore.selectedCurrencies.contains(where: { $0.code == currency.code })
                }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Currency type picker
                Picker("Currency Type", selection: $selectedType) {
                    Text("Fiat").tag(Currency.CurrencyType.fiat)
                    Text("Crypto").tag(Currency.CurrencyType.crypto)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Currency list
                List(availableCurrencies, id: \.code) { currency in
                    CurrencySelectionRowView(
                        currency: currency,
                        onTap: {
                            addCurrency(currency)
                        }
                    )
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText, prompt: "Search currencies...")
            }
            .navigationTitle("Add Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addCurrency(_ currency: Currency) {
        currencyStore.addCurrency(currency)
        dismiss()
    }
}

// MARK: - Currency Selection Row View

struct CurrencySelectionRowView: View {
    let currency: Currency
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Currency flag/icon
                Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
                
                // Currency info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(currency.code)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Currency type badge
                        Text(currency.type.rawValue.uppercased())
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(currency.type == .fiat ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                            )
                            .foregroundColor(currency.type == .fiat ? .blue : .orange)
                    }
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Add icon
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct CurrencySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelectionView(currencyStore: CurrencyStore())
    }
}
