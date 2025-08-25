import UIKit

class CurrencySelectionViewController: UITableViewController {
    
    private let segmentedControl = UISegmentedControl(items: ["Fiat", "Crypto"])
    private var allCurrencies: [Currency] = []
    private var filteredCurrencies: [Currency] = []
    private var selectedCurrencies: [Currency] = CurrencyService.shared.loadSelectedCurrencies()
    private var searchController : UISearchController!
    private var currentType: Currency.CurrencyType = .fiat
    weak var delegate: CurrencySelectionDelegate?
    
    private var currencies: [Currency] {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty ? filteredCurrencies : allCurrencies
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
        setupSearchController()
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search currencies..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func loadCurrencies(for type: Currency.CurrencyType) {
        currentType = type
        allCurrencies = CurrencyService.shared.getAvailableCurrencies(for: type)
        filteredCurrencies = allCurrencies
        tableView.reloadData()
    }
    
    private func filterCurrencies(with searchText: String) {
        if searchText.isEmpty {
            filteredCurrencies = allCurrencies
        } else {
            filteredCurrencies = allCurrencies.filter { currency in
                currency.code.lowercased().contains(searchText.lowercased()) ||
                currency.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
    
    private func isCurrencySelected(_ currency: Currency) -> Bool {
        return selectedCurrencies.contains { $0.code == currency.code }
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let type: Currency.CurrencyType = sender.selectedSegmentIndex == 0 ? .fiat : .crypto
        loadCurrencies(for: type)
    }
    
    @objc private func starButtonTapped(_ sender: UIButton) {
        let currency = currencies[sender.tag]
        
        if isCurrencySelected(currency) {
            removeCurrency(currency)
        } else {
            addCurrency(currency)
        }
        
        let indexPath = IndexPath(row: sender.tag, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc private func starButtonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    @objc private func starButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }
    
    private func addCurrency(_ currency: Currency) {
        CurrencyService.shared.addCurrency(currency)
        selectedCurrencies.append(currency)
        delegate?.didSelectCurrency(currency)
    }
    
    private func removeCurrency(_ currency: Currency) {
        selectedCurrencies.removeAll { $0.code == currency.code }
        var allCurrencies = CurrencyService.shared.loadSelectedCurrencies()
        allCurrencies.removeAll { $0.code == currency.code }
        CurrencyService.shared.saveSelectedCurrencies(allCurrencies)
        delegate?.didSelectCurrency(currency)
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
        cell.selectionStyle = .none
        
        let starButton = UIButton(type: .system)
        starButton.tag = indexPath.row
        starButton.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
        
        let isSelected = isCurrencySelected(currency)
        let starImage = UIImage(systemName: isSelected ? "star.fill" : "star")
        starButton.setImage(starImage, for: .normal)
        starButton.tintColor = isSelected ? .systemYellow : .systemGray3
        
        starButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        starButton.contentHorizontalAlignment = .center
        starButton.contentVerticalAlignment = .center
        
        starButton.addTarget(self, action: #selector(starButtonTouchDown(_:)), for: .touchDown)
        starButton.addTarget(self, action: #selector(starButtonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        cell.accessoryView = starButton
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Row selection disabled - only star button works
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: .curveEaseInOut) {
            cell.alpha = 1
        }
    }
}

// MARK: - UISearchResultsUpdating
extension CurrencySelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filterCurrencies(with: searchText)
    }
}
