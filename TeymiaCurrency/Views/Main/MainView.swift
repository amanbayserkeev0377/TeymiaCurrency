import SwiftUI

struct MainView: View {
    @StateObject private var currencyStore = CurrencyStore()
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var showingCurrencySelection = false
    @State private var showingSettings = false
    
    @FocusState private var focusedCurrency: String?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(currencyStore.selectedCurrencies, id: \.code) { currency in
                    CurrencyRowView(
                        currency: currency,
                        currencyStore: currencyStore,
                        focusedCurrency: $focusedCurrency  // ✅ Pass binding
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if currencyStore.canRemoveMore {
                            Button(role: .destructive) {
                                currencyStore.removeCurrency(currency)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                .onMove(perform: moveCurrencies)
            }
            .listStyle(PlainListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image("icon_settings")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCurrencySelection = true
                    }) {
                        Image("icon_plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        hideKeyboard()
                    }) {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .onAppear {
                currencyStore.fetchRatesIfNeeded()
            }
            .sheet(isPresented: $showingCurrencySelection) {
                CurrencySelectionView(currencyStore: currencyStore)
                    .preferredColorScheme(themeMode.colorScheme)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .preferredColorScheme(themeMode.colorScheme)
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
    
    private func moveCurrencies(from source: IndexSet, to destination: Int) {
        currencyStore.moveCurrency(from: source, to: destination)
    }
    
    private func hideKeyboard() {
        focusedCurrency = nil
    }
}
