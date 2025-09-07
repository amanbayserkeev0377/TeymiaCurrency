import Foundation

enum AppIcon {
    case main
    case alternate(name: String, imageName: String)
    
    static let allIcons: [AppIcon] = [
        .main,
        .alternate(name: "AppIconGold", imageName: "preview_appicon_gold"),
        .alternate(name: "AppIconGlobe", imageName: "preview_appicon_globe"),
        .alternate(name: "AppIconPurple", imageName: "preview_appicon_purple"),
        .alternate(name: "AppIconGreen", imageName: "preview_appicon_green"),
        .alternate(name: "AppIconBlue", imageName: "preview_appicon_blue")
    ]
    
    /// Name for alternate icon (nil for main icon)
    var name: String? {
        switch self {
        case .main:
            return nil
        case .alternate(let name, _):
            return name
        }
    }
    
    /// Image name for preview in settings
    var imageName: String {
        switch self {
        case .main:
            return "preview_appicon_main"
        case .alternate(_, let imageName):
            return imageName
        }
    }
}

// MARK: - Conformances
extension AppIcon: Hashable, Identifiable {
    var id: String {
        switch self {
        case .main:
            return "main"
        case .alternate(let name, _):
            return name
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AppIcon: Equatable {
    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        lhs.id == rhs.id
    }
}
