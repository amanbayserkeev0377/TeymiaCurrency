import Foundation

enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case blue = "AppIcon-Blue"
    case globe = "AppIcon-Globe"
    case gold = "AppIcon-Gold"
    case purple = "AppIcon-Purple"
    case white = "AppIcon-White"
    case yuan = "AppIcon-Yuan"
    
    var id: String { rawValue }
    
    // Name for UIApplication.setAlternateIconName
    var name: String? {
        self == .main ? nil : rawValue
    }
    
    // Preview image name for settings
    var previewImageName: String {
        "Preview-\(rawValue)"
    }
    
    // All icons as array
    static var allIcons: [AppIcon] {
        AppIcon.allCases
    }
}
