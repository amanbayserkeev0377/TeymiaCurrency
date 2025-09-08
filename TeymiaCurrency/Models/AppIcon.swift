import Foundation

enum AppIcon {
    case main
    case alternate(name: String, imageName: String)
    
    static let allIcons: [AppIcon] = [
        .main,
        .alternate(name: "AppIconDollar", imageName: "preview_appicon_dollar"),
        .alternate(name: "AppIconDollar2", imageName: "preview_appicon_dollar2"),
        .alternate(name: "AppIconDollar3", imageName: "preview_appicon_dollar3"),
        .alternate(name: "AppIconDollar4", imageName: "preview_appicon_dollar4"),
        .alternate(name: "AppIconGreen", imageName: "preview_appicon_green"),
        .alternate(name: "AppIconGold", imageName: "preview_appicon_gold"),
        .alternate(name: "AppIconPink", imageName: "preview_appicon_pink"),
        .alternate(name: "AppIconPurple", imageName: "preview_appicon_purple"),
        .alternate(name: "AppIconYuan", imageName: "preview_appicon_yuan"),
        .alternate(name: "AppIconGlobe", imageName: "preview_appicon_globe"),
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
