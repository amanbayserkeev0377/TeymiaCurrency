# 💱 Teymia Currency - Converter

A minimalist currency converter for iOS featuring real-time exchange rates for 160+ fiat currencies and 70+ cryptocurrencies.

<p align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" alt="iOS 16.0+"/>
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9"/>
  <img src="https://img.shields.io/badge/SwiftUI-✓-green.svg" alt="SwiftUI"/>
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License MIT"/>
</p>

## ✨ Features

- 🌍 **160+ Fiat Currencies** - Support for all major world currencies
- ₿ **70+ Cryptocurrencies** - Bitcoin, Ethereum, and more
- 🎨 **Theme Support** - System, Light, and Dark modes
- 📱 **Multiple App Icons** - beautiful icon options
- 💾 **Offline Support** - Cached rates work without internet
- 🔄 **Auto-Refresh** - Rates update every 6 hours automatically
- 🎯 **Real-time Conversion** - Live updates as you type
- 🌐 **Localized** - Support for multiple languages
- ⚡ **Fast & Lightweight** - Minimal dependencies, pure SwiftUI

## 📱 Screenshots

/Users/amanbayserkeev/Documents/TeymiaCurrency/AppStoreScreenshots/AppStore/1.png
*Add your app screenshots here*

## 🛠 Tech Stack

### Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Minimum iOS**: 16.0+
- **Language**: Swift 5.9

### APIs
- **Fiat Currencies**: [ExchangeRate API](https://exchangerate-api.com)
- **Cryptocurrencies**: [CoinGecko API](https://coingecko.com)

### Data Persistence
- UserDefaults for currency selection and rate caching

## 📂 Project Structure

```
TeymiaCurrency/
├── Models/
│   ├── Currency.swift              # Currency data model
│   ├── AppIcon.swift                # App icon configuration
│   └── CurrencyData.swift           # Static currency data
├── ViewModels/
│   └── CurrencyStore.swift          # Main ViewModel with conversion logic
├── Views/
│   ├── MainView.swift               # Main currency list screen
│   ├── CurrencyRowView.swift        # Individual currency row
│   ├── CurrencySelectionView.swift  # Currency picker
│   └── Settings/
│       ├── SettingsView.swift
│       ├── AppearanceSection.swift
│       └── LanguageSection.swift
├── Services/
│   ├── APIService.swift             # Network layer
│   └── CurrencyService.swift        # Business logic
├── Managers/
│   └── AppIconManager.swift         # App icon management
├── Utilities/
│   ├── Constants.swift              # App constants
│   ├── Extensions.swift             # Helper extensions
│   └── Localizable.strings          # Localization
└── Resources/
    └── Assets.xcassets              # Images and icons
```

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- macOS 13.0+ (for development)

### Installation

1. Clone the repository
```bash
git clone https://github.com/amanbayserkeev0377/TeymiaCurrency.git
cd TeymiaCurrency
```

2. Open the project in Xcode
```bash
open TeymiaCurrency.xcodeproj
```

3. Build and run
- Select your target device
- Press `Cmd + R` to build and run

### API Keys

This project uses free tier APIs that don't require API keys:
- **ExchangeRate API**: Free tier with 1,500 requests/month
- **CoinGecko API**: Free tier with rate limits

## 💡 Key Features Explained

### Real-time Conversion
The app uses a centralized `@FocusState` to manage which currency field is being edited, ensuring smooth and bug-free conversion between currencies.

### Caching Strategy
Exchange rates are cached locally and refreshed every 6 hours. This provides:
- Offline functionality
- Reduced API calls
- Faster app startup

### Number Formatting
- **Thousand separator**: Space (` `)
- **Decimal separator**: Comma (`,`)
- **Crypto precision**: Up to 8 decimal places
- **Fiat precision**: 2-4 decimal places

Example: `1 000 000,50`

## 🎨 Customization

### Adding New Currencies

1. Add the currency to `CurrencyData.swift`:
```swift
static let newCurrency = Currency(
    code: "XYZ",
    name: "New Currency",
    type: .fiat // or .crypto
)
```

2. For crypto, add mapping in `APIService.swift`:
```swift
private func cryptoCodeToCoinGeckoId(_ code: String) -> String? {
    let mapping: [String: String] = [
        // ... existing mappings
        "XYZ": "coin-gecko-id"
    ]
    return mapping[code]
}
```

### Adding New App Icons

1. Add icon assets to `Assets.xcassets`
2. Update `AppIcon.swift`:
```swift
enum AppIcon: String, CaseIterable {
    case main = "AppIcon"
    case newIcon = "AppIcon-NewIcon"
    // ...
}
```

## 🧪 Testing

The app includes manual testing scenarios. To test:

1. **Conversion Accuracy**: Verify rates against official sources
2. **Offline Mode**: Disable internet and test cached rates
3. **Theme Switching**: Test all theme combinations
4. **Currency Management**: Add/remove/reorder currencies

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Guidelines

- Follow Swift API Design Guidelines
- Use MARK comments for code organization
- Document public APIs with `///` comments
- Keep views focused and composable
- Write descriptive commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ExchangeRate API](https://exchangerate-api.com) for fiat currency data
- [CoinGecko](https://coingecko.com) for cryptocurrency data
- Currency flags from various open-source collections

## 📧 Contact

Aman Bayserkeev - [@amanbayserkeev0377](https://github.com/amanbayserkeev0377)

Project Link: [https://github.com/amanbayserkeev0377/TeymiaCurrency](https://github.com/amanbayserkeev0377/TeymiaCurrency)

App Store: [Download on the App Store](https://apps.apple.com/app/id6752235997)

---

<p align="center">Made with ❤️ in Kyrgyzstan</p>
