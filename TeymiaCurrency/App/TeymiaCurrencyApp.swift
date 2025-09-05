import SwiftUI

@main
struct TeymiaCurrencyApp: App {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeMode") private var themeMode: ThemeMode = .system
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(themeMode.colorScheme)
        }
    }
}

enum ThemeMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
