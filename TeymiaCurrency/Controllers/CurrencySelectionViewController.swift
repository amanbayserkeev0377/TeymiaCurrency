import UIKit

class CurrencySelectionViewController: UITableViewController {
    
    private let segmentedControl = UISegmentedControl(items: ["Fiat", "Crypto"])
    private var currencies: [Currency] = []
    private var currentType: Currency.CurrencyType = .fiat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
        loadCurrencies(for: .fiat)
    }
    
    private func setupViewController() {
        view.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "selectionCell")
    }
    
    private func setupNavigationBar() {
        title = "Add Currency"
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                         target: self,
                                                         action: #selector(cancelButtonTapped))
    }
    
    private func loadCurrencies(for type: Currency.CurrencyType) {
        currentType = type
        currencies = CurrencyService.shared.getAvailableCurrencies(for: type)
        tableView.reloadData()
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let type: Currency.CurrencyType = sender.selectedSegmentIndex == 0 ? .fiat : .crypto
        loadCurrencies(for: type)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "selectionCell")
        let currency = currencies[indexPath.row]
        
        cell.textLabel?.text = currency.code
        cell.detailTextLabel?.text = currency.name
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCurrency = currencies[indexPath.row]
        print("Selected currency: \(selectedCurrency.code)")
        
        // TODO: Здесь будем добавлять валюту в избранное
        // и обновлять главный экран
        
        dismiss(animated: true)
    }
}
