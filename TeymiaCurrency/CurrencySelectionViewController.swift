import UIKit

class CurrencySelectionViewController: UITableViewController {
    
    private let segmentedControl = UISegmentedControl(items: ["Fiat", "Crypto"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupNavigationBar()
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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        print("currency selection segment changed: \(sender.selectedSegmentIndex)")
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
