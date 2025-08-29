import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var autoRefresh = true
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // App Settings Section
                Section("Settings") {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Toggle("Auto Refresh Rates", isOn: $autoRefresh)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading) {
                            Text("Refresh Interval")
                            Text("Every 5 minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("5 min")
                            .foregroundColor(.secondary)
                    }
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
                
                // About Section
                Section("About") {
                    Button(action: { showAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text("About Teymia Currency")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                            .frame(width: 20)
                        
                        Text("Rate App")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Icon placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 8) {
                    Text("Teymia Currency")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Text("A simple and elegant currency converter with support for 160+ fiat currencies and popular cryptocurrencies.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("Features:")
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Real-time exchange rates")
                            Text("• 160+ fiat currencies")
                            Text("• Popular cryptocurrencies")
                            Text("• Offline mode with cached rates")
                            Text("• Clean, minimal design")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Made with ❤️ in Kyrgyzstan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 Teymia Currency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
