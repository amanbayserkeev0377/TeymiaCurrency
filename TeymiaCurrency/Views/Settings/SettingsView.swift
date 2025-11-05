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
                // MARK: - About
                Section {
                    // Rate
                    Button {
                        if let url = URL(string: "https://apps.apple.com/app/id6752235997") {
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
                    }
                    
                    // Share
                    ShareLink(
                        item: URL(string: "https://apps.apple.com/app/id6752235997")!
                    ) {
                        Label(
                            title: { Text("share_app".localized) },
                            icon: {
                                Image("icon_share")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                    }
                }
                
                // MARK: - LEGAL
                Section {
                    // Privacy Policy
                    Button {
                        if let url = URL(string: "https://www.notion.so/Privacy-Policy-267d5178e65a8017ad5afda2e3f004fc") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label(
                            title: { Text("privacy_policy".localized) },
                            icon: {
                                Image("icon_lock")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                    }
                    
                    // Terms of Service
                    Button {
                        if let url = URL(string: "https://www.notion.so/Terms-of-Service-267d5178e65a804a9e80d8660c798b57") {
                            UIApplication.shared.open(url)
                        } // <- CHANGE TO REAL URL
                    } label: {
                        Label(
                            title: { Text("terms_of_service".localized) },
                            icon: {
                                Image("icon_document")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        )
                    }
                    
                    // Licenses
                    ZStack {
                        NavigationLink(destination: LicensesView()) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            Label(
                                title: { Text("licenses".localized) },
                                icon: {
                                    Image("icon_list")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                            )
                            
                            Spacer()
                            
                            Image("icon_chevron_right")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .navigationTitle("settings".localized)
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
