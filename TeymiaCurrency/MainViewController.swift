import UIKit

class MainViewController: UITableViewController {
    
    private var currencies: [String] = ["USD", "EUR", "KZT", "RUB"]
    private var fabButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
        setupFABButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fabButton.frame = CGRect(x: view.frame.width - 80, y: view.frame.height - 100, width: 60, height: 60)
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
        fabButton.backgroundColor = .label
        fabButton.tintColor = .white
        fabButton.setImage(UIImage(systemName: "plus"), for: .normal)
        fabButton.layer.cornerRadius = 30
        fabButton.layer.shadowColor = UIColor.black.cgColor
        fabButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        fabButton.layer.shadowRadius = 4
        fabButton.layer.shadowOpacity = 0.3
        
        fabButton.addTarget(self, action: #selector(fabButtonTapped), for: .touchUpInside)
        
        view.addSubview(fabButton)
    }
    
    // MARK: - Actions
    @objc private func fabButtonTapped() {
        print("FAB button tapped")
        
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "currencyCell"
        )
        let currency = currencies[indexPath.row]
        cell.textLabel?.text = currency
        cell.detailTextLabel?.text = "1 \(currency) = ..."
        
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
