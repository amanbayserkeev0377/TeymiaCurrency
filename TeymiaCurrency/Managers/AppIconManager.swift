import SwiftUI
import UIKit
import OSLog

@MainActor
final class AppIconManager: ObservableObject {
    static let shared = AppIconManager()
    
    @Published var currentIcon: AppIcon
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeymiaCurrency", category: "AppIconManager")
    
    private init() {
        currentIcon = Self.getCurrentAppIcon()
    }
    
    static func getCurrentAppIcon() -> AppIcon {
        let currentName = UIApplication.shared.alternateIconName
        return AppIcon.allIcons.first { $0.name == currentName } ?? .main
    }
    
    func setAppIcon(_ icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            logger.warning("Alternate icons not supported")
            return
        }
        
        guard currentIcon != icon else {
            logger.debug("Icon already set")
            return
        }
        
        // Update immediately for UI responsiveness
        currentIcon = icon
        
        UIApplication.shared.setAlternateIconName(icon.name) { [weak self] error in
            if let error = error {
                self?.logger.error("Failed to set app icon: \(error.localizedDescription)")
                // Revert to actual icon if failed
                Task { @MainActor in
                    self?.currentIcon = Self.getCurrentAppIcon()
                }
            } else {
                self?.logger.info("Successfully set app icon")
            }
        }
    }
}
