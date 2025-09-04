import SwiftUI

struct CurrencySelectionView: View {
    @ObservedObject var currencyStore: CurrencyStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: Currency.CurrencyType = .fiat
    @State private var searchText = ""
    @State private var showingSearchResults = false
    
    private var availableCurrencies: [Currency] {
        let currencies = selectedType == .fiat ? CurrencyData.fiatCurrencies : CurrencyData.cryptoCurrencies
        
        if searchText.isEmpty {
            return currencies
        } else {
            return currencies.filter { currency in
                currency.code.lowercased().contains(searchText.lowercased()) ||
                currency.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            // Currency list
            List(availableCurrencies, id: \.code) { currency in
                CurrencySelectionRowView(
                    currency: currency,
                    isSelected: currencyStore.selectedCurrencies.contains(where: { $0.code == currency.code }),
                    onTap: {
                        toggleCurrency(currency)
                    }
                )
            }
            .listStyle(PlainListStyle())
            .searchable(text: $searchText, prompt: "Search currencies...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Currency type picker in navigation bar
                    Picker("Currency Type", selection: $selectedType) {
                        Text("Fiat").tag(Currency.CurrencyType.fiat)
                        Text("Crypto").tag(Currency.CurrencyType.crypto)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image("icon_xmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
    
    private func toggleCurrency(_ currency: Currency) {
        if currencyStore.selectedCurrencies.contains(where: { $0.code == currency.code }) {
            // Remove from favorites
            currencyStore.removeCurrency(currency)
        } else {
            // Add to favorites
            currencyStore.addCurrency(currency)
        }
    }
}

// MARK: - Currency Selection Row View

struct CurrencySelectionRowView: View {
    let currency: Currency
    let isSelected: Bool
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
                    }
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Favorite star icon
                Image("icon_star2")
                    .resizable()
                    .foregroundStyle(isSelected ? .yellow : .gray)
                    .frame(width: 26, height: 26)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
