import SwiftUI
import UIKit

// MARK: - App Icon
enum AppIcon: Hashable, Identifiable {
    case main
    case gold(name: String)
    case globe(name: String)
    
    static let allIcons: [AppIcon] = [
        .main,
        .gold(name: "AppIconGold"),
        .globe(name: "AppIconGlobe")
    ]
    
    var id: String {
        switch self {
        case .main: return "main"
        case .gold(let name): return name
        case .globe(let name): return name
        }
    }
    
    /// Name for AppIconSet in Assets
    var name: String? {
        switch self {
        case .main: return nil
        case .gold(let name): return name
        case .globe(let name): return name
        }
    }
    
    /// Name for ImageSet in Assets for UI preview
    var preview: String {
        switch self {
        case .main: return "preview_appicon_main"
        case .gold(_): return "preview_appicon_gold"
        case .globe(_): return "preview_appicon_globe"
        }
    }
}

// MARK: - AppIconManager

class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    
    @Published private(set) var currentIcon: AppIcon
    
    private init() {
        currentIcon = Self.getCurrentAppIcon()
    }
    
    static func getCurrentAppIcon() -> AppIcon {
        if let alternateIconName = UIApplication.shared.alternateIconName {
            if let matchingIcon = AppIcon.allIcons.first(where: { $0.name == alternateIconName }) {
                return matchingIcon
            }
        }
        return .main
    }
    
    func setAppIcon(_ icon: AppIcon) {
        applySpecificIcon(icon.name)
        currentIcon = icon
    }
    
    // MARK: - Private Methods
    
    private func applySpecificIcon(_ iconName: String?) {
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }
        
        let currentIconName = UIApplication.shared.alternateIconName
        
        // Skip if the icon is already set
        if currentIconName == iconName {
            return
        }
        
        // Apply the icon
        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            if error == nil {
                if let self = self {
                    Task { @MainActor in
                        self.currentIcon = Self.getCurrentAppIcon()
                    }
                }
            }
        }
    }
}
