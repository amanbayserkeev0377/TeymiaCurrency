import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    @State private var autoRefresh = true
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    AppearanceSection()
                    LanguageSection()
                }
                
                // Data Sources Section
                Section("Data Sources") {
                    HStack {
                        Image(systemName: "banknote")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Fiat Currencies")
                            Text("ExchangeRate API")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "bitcoinsign.circle")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Cryptocurrencies")
                            Text("CoinGecko API")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Auto-Update Section
                Section("Auto-Update") {
                    HStack {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Refresh Interval")
                            Text("Every 6 hours automatically")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("6h")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Offline Mode")
                            Text("Uses cached rates when offline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // MARK: - About
                Section {
                    // Rate
                    Button {
                        if let url = URL(string: "https://apps.apple.com/app/id6746747903") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label(
                            title: { Text("rate_app".localized) },
                            icon: {
                                Image("icon_star")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                        .withExternalLinkIcon()
                    }
                    .tint(.primary)
                    
                    // Share
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id6746747903")!
                    ) {
                        Label(
                            title: { Text("share_app".localized) },
                            icon: {
                                Image("icon_share")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                        .withExternalLinkIcon()
                    }
                    .tint(.primary)
                    
                    NavigationLink {
                        LicensesView()
                    } label: {
                        Label(
                            title: { Text("licenses".localized) },
                            icon: {
                                Image("icon_list")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:  {
                        dismiss()
                    }) {
                        Image("icon_xmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
    }
}
