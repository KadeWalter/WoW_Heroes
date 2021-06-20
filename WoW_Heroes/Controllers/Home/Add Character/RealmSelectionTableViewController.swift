//
//  RealmSelectionTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 6/20/21.
//  Copyright © 2021 Kade Walter. All rights reserved.
//

import UIKit

protocol RealmSelectionDelegate: AnyObject {
    func realmSelected(realm: Realm)
}

class RealmSelectionViewController: UIViewController {

    // Delegate
    var realmSelectionDelegate: RealmSelectionDelegate?

    // Views
    private lazy var stackView = lazyStackView()
    private var searchBar = UISearchBar()
    private var tableView = UITableView()
    
    // Private Vars
    private var searchRealms: [Realm] = []
    private var realms: [Realm] = []
    
    init(withRealms realms: [Realm]) {
        self.realms = realms
        super.init(nibName: nil, bundle: nil)
        self.title = localizedSelectARealm()
        self.view.backgroundColor = .systemGroupedBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        initializeViews()
        buildTableModel()
    }
    
    private func buildTableModel() {
        searchRealms = realms
        tableView.reloadData()
    }
}

// MARK: - Search Bar Delegate Function
extension RealmSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchRealms = realms
        } else {
            searchRealms = realms.filter({ ($0.name.contains(searchText)) })
        }
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate and DataSource Functions
extension RealmSelectionViewController:  UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchRealms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "realmCell")
        cell.textLabel?.text = searchRealms[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        realmSelectionDelegate?.realmSelected(realm: searchRealms[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Localized Strings
extension RealmSelectionViewController {
    private func localizedSelectARealm() -> String {
        return NSLocalizedString("Select A Realm", tableName: "RealmSelection", bundle: .main, value: "realm selection", comment: "realm selection")
    }
    
    private func localizedSearch() -> String {
        return NSLocalizedString("Search", tableName: "RealmSelection", bundle: .main, value: "search", comment: "search")
    }
}

extension RealmSelectionViewController {
    private func initializeViews() {
        let guide = self.view.safeAreaLayoutGuide
        
        setupSearchBar()
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(tableView)
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
    
    private func lazyStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func setupSearchBar() {
        self.searchBar.searchBarStyle = .default
        self.searchBar.placeholder = localizedSearch()
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.delegate = self
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
    }
}
