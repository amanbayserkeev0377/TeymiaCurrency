import SwiftUI

struct LicensesView: View {
    var body: some View {
        List {
            Section("licenses_section_attributions".localized) {
                LicenseRow(iconName: "icon_settings", attribution: "UI icons", url: "https://icons8.com/icons/liquid-glass")
                LicenseRow(iconName: "USD", attribution: "Country flags", url: "https://www.flaticon.com/packs/countrys-flags?word=flags")
                LicenseRow(iconName: "BTC", attribution: "Cryptocurrency", url: "https://www.flaticon.com/packs/cryptocurrency-15207963")
                LicenseRow(iconName: "preview_appicon_main", attribution: "Exchange icon", url: "https://www.vecteezy.com/png/13391079-cryptocurrency-exchange-3d-illustration", iconSize: 30)
            }
        }
        .navigationTitle("licenses".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicenseRow: View {
    let iconName: String
    let attribution: String
    let url: String
    let iconSize: CGFloat
    
    init(iconName: String, attribution: String, url: String, iconSize: CGFloat = 26) {
        self.iconName = iconName
        self.attribution = attribution
        self.url = url
        self.iconSize = iconSize
    }
    
    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                Text(attribution)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .withExternalLinkIcon()
        }
        .tint(.primary)
    }
    
    private var cornerRadius: CGFloat {
        switch iconSize {
        case ...30: return 6
        case 31...40: return 8
        case 41...48: return 10
        default: return 12
        }
    }
}

// MARK: - External Link Modifier

struct ExternalLinkModifier: ViewModifier {
    var trailingText: String? = nil
    
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            
            if let text = trailingText {
                Text(text)
                    .foregroundStyle(.secondary)
            }
            
            Image(systemName: "arrow.up.right")
                .font(.footnote)
                .fontWeight(.bold)
                .foregroundStyle(.tertiary)
        }
    }
}



extension View {
    func withExternalLinkIcon(trailingText: String? = nil) -> some View {
        self.modifier(ExternalLinkModifier(trailingText: trailingText))
    }
}
