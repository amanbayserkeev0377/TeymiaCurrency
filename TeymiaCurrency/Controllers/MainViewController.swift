import UIKit

class MainViewController: UITableViewController {
    
    private var currencies: [Currency] = CurrencyService.shared.loadSelectedCurrencies()
    private var fabButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
        setupFABButton()
        
        loadCurrencies()
    }
        
    private func setupViewController() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        title = "Teymia Currency"
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func setupFABButton() {
        fabButton = UIButton(type: .system)
        fabButton.backgroundColor = .systemBlue
        fabButton.tintColor = .white
        fabButton.setImage(UIImage(systemName: "plus"), for: .normal)
        fabButton.layer.cornerRadius = 30
        fabButton.layer.shadowColor = UIColor.black.cgColor
        fabButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        fabButton.layer.shadowRadius = 8
        fabButton.layer.shadowOpacity = 0.3
        
        fabButton.addTarget(self, action: #selector(fabButtonTapped), for: .touchUpInside)
        
        fabButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        fabButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fabButton)
        
        NSLayoutConstraint.activate([
            fabButton.widthAnchor.constraint(equalToConstant: 60),
            fabButton.heightAnchor.constraint(equalToConstant: 60),
            fabButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            fabButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadCurrencies() {
        currencies = CurrencyService.shared.loadSelectedCurrencies()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func fabButtonTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.fabButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.fabButton.transform = CGAffineTransform.identity
            }
        }
        let selectionVC = CurrencySelectionViewController()
        let navController = UINavigationController(rootViewController: selectionVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        print("Settings button tapped")
        
        let settingsVC = SettingsViewController()
        let navController = UINavigationController(rootViewController: settingsVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "currencyCell")
        let currency = currencies[indexPath.row]
                
        cell.textLabel?.text = "\(currency.code) - \(currency.name)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCurrency = currencies.remove(at: sourceIndexPath.row)
        currencies.insert(movedCurrency, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             currencies.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .automatic)
         }
     }
}
