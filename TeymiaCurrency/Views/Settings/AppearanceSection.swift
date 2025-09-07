import SwiftUI

struct ThemeOption {
    let name: String
    let iconName: String
    
    static let system = ThemeOption(name: "appearance_system".localized, iconName: "icon_blackwhite")
    static let light = ThemeOption(name: "appearance_light".localized, iconName: "icon_sun")
    static let dark = ThemeOption(name: "appearance_dark".localized, iconName: "icon_moon")
    
    static let allOptions = [system, light, dark]
}

// MARK: - Appearance Section for SettingsView
struct AppearanceSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            NavigationLink(destination: AppearanceView()) {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Label(
                    title: { Text("appearance".localized) },
                    icon: {
                        Image("icon_moon")
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

// MARK: - Appearance View
struct AppearanceView: View {
    @ObservedObject private var iconManager = AppIconManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some View {
        Form {
            Section {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeMode = mode
                        }
                    } label: {
                        HStack {
                            Image(ThemeOption.allOptions[mode.rawValue].iconName)
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text(ThemeOption.allOptions[mode.rawValue].name)
                            
                            Spacer()
                            
                            Image("icon_checkmark")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(themeMode == mode ? 1 : 0)
                                .animation(.easeInOut, value: themeMode == mode)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("appearance_mode".localized)
            }
            
            // App Icon Selection
            Section {
                AppIconGridView(
                    selectedIcon: iconManager.currentIcon,
                    onIconSelected: { icon in
                        iconManager.setAppIcon(icon)
                    }
                )
            } header: {
                Text("app_icon".localized)
            }
        }
        .navigationTitle("appearance".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - App Icon Grid
struct AppIconGridView: View {
    let selectedIcon: AppIcon
    let onIconSelected: (AppIcon) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(AppIcon.allIcons) { icon in
                AppIconButton(
                    icon: icon,
                    isSelected: selectedIcon == icon,
                    onTap: {
                        onIconSelected(icon)
                    }
                )
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - App Icon Button
struct AppIconButton: View {
    let icon: AppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(icon.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? .gray : .gray.opacity(0.3),
                               lineWidth: isSelected ? 2 : 0.3)
                )
        }
        .buttonStyle(.plain)
    }
}
