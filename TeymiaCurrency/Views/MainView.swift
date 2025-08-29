import SwiftUI

struct MainView: View {
    @StateObject private var currencyStore = CurrencyStore()
    @State private var showingCurrencySelection = false
    @State private var showingSettings = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Currency list - always has at least 1 currency
                CurrencyListView(
                    currencies: currencyStore.selectedCurrencies,
                    currencyStore: currencyStore,
                    isEditing: isEditing
                )
                
                // FAB Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingCurrencySelection = true
                        }) {
                            Image("icon_plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(.primary).opacity(0.8)
                                .frame(width: 58, height: 58)
                                .background(
                                    Circle()
                                        .fill(Color(.systemGray6).opacity(0.7))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary.opacity(0.1), lineWidth: 0.2)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    }) {
                        Image(isEditing ? "icon_checkmark" : "icon_list")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image("icon_settings")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
                // Keyboard toolbar with global dismiss
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: {
                        // Dismiss any focused keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                       to: nil, from: nil, for: nil)
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
}

// MARK: - Currency List View

struct CurrencyListView: View {
    let currencies: [Currency]
    let currencyStore: CurrencyStore
    let isEditing: Bool
    
    var body: some View {
        List {
            ForEach(currencies, id: \.code) { currency in
                CurrencyRowView(currency: currency, currencyStore: currencyStore)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if currencyStore.canRemoveMore {
                            Button(role: .destructive) {
                                currencyStore.removeCurrency(currency)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
            }
            .onDelete(perform: isEditing ? deleteCurrencies : nil)
            .onMove(perform: isEditing ? moveCurrencies : nil)
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
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

#Preview {
    MainView()
}
