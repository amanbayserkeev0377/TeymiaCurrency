import SwiftUI

struct MainView: View {
    @StateObject private var currencyStore = CurrencyStore()
    @State private var showingCurrencySelection = false
    @State private var showingSettings = false
    @State private var selectedCurrencyType: Currency.CurrencyType = .fiat
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    // Segmented control for currency type
                    Picker("Currency Type", selection: $selectedCurrencyType) {
                        Text("Fiat").tag(Currency.CurrencyType.fiat)
                        Text("Crypto").tag(Currency.CurrencyType.crypto)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Currency list
                        CurrencyListView(
                            currencies: filteredCurrencies,
                            currencyStore: currencyStore
                        )
                }
                
                // FAB Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCurrencySelection = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Teymia Currency")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .refreshable {
                currencyStore.fetchRates()
            }
            .onAppear {
                currencyStore.fetchRatesIfNeeded()
            }
            .sheet(isPresented: $showingCurrencySelection) {
                CurrencySelectionView(currencyStore: currencyStore)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Error", isPresented: .constant(currencyStore.errorMessage != nil)) {
                Button("OK") {
                    currencyStore.errorMessage = nil
                }
            } message: {
                Text(currencyStore.errorMessage ?? "")
            }
        }
    }
    
    private var filteredCurrencies: [Currency] {
        currencyStore.selectedCurrencies.filter { $0.type == selectedCurrencyType }
    }
}

// MARK: - Currency List View

struct CurrencyListView: View {
    let currencies: [Currency]
    let currencyStore: CurrencyStore
    
    var body: some View {
        List {
            ForEach(currencies, id: \.code) { currency in
                CurrencyRowView(currency: currency, currencyStore: currencyStore)
            }
            .onDelete(perform: deleteCurrencies)
            .onMove(perform: moveCurrencies)
        }
        .listStyle(PlainListStyle())
    }
    
    private func deleteCurrencies(offsets: IndexSet) {
        for index in offsets {
            currencyStore.removeCurrency(currencies[index])
        }
    }
    
    private func moveCurrencies(from source: IndexSet, to destination: Int) {
        currencyStore.moveCurrency(from: source, to: destination)
    }
}
