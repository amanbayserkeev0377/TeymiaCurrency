import Foundation

protocol CurrencySelectionDelegate: AnyObject {
    func didSelectCurrency(_ currency: Currency)
}
