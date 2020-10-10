//
//  RegionSelectTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/27/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class RegionSelectTableViewController: UITableViewController {
    
    var addCharacterDelegate: CharacterAddedDelegate?
    var tableModel: [RegionSelectTableModel] = []
    let cellReuseIdentifier = "RegionSelectTableViewCell"
    
    init() {
        super.init(style: .grouped)
        self.title = localizedTitle()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTableModel()
    }
    
    private func buildTableModel() {
        tableModel.append(RegionSelectTableModel(region: "US"))
        tableModel.append(RegionSelectTableModel(region: "EU"))
        tableModel.append(RegionSelectTableModel(region: "KR"))
        tableModel.append(RegionSelectTableModel(region: "TW"))
    }
}

// MARK: - TableView Delegate and DataSource Functions
extension RegionSelectTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = tableModel[indexPath.row].region
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = AddCharacterTableViewController(region: tableModel[indexPath.row].region.lowercased())
        vc.addCharacterDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RegionSelectTableViewController: CharacterAddedDelegate {
    func characterAdded() {
        addCharacterDelegate?.characterAdded()
    }
}

// MARK: - TableModel
extension RegionSelectTableViewController {
    struct RegionSelectTableModel {
        var region: String
    }
}

// MARK: - Localized Strings
extension RegionSelectTableViewController {
    private func localizedTitle() -> String {
        return NSLocalizedString("Region Select Title", tableName: "RegionSelect", bundle: .main, value: "region select title", comment: "region select title")
    }
}
