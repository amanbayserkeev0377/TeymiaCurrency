import SwiftUI

struct CurrencyRowView: View {
    let currency: Currency
    @ObservedObject var currencyStore: CurrencyStore
    
    var body: some View {
        HStack(spacing: 12) {
            // Currency flag/icon
            AsyncImage(url: nil) { _ in
                Image(CurrencyService.shared.getCurrencyIcon(for: currency))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            }
            
            // Currency info
            VStack(alignment: .leading, spacing: 2) {
                Text(currency.code)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(currency.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Exchange rate
            VStack(alignment: .trailing, spacing: 2) {
                Text(currencyStore.getFormattedRate(for: currency))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let lastUpdate = currencyStore.lastUpdateTime {
                    Text(formatRelativeTime(lastUpdate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
