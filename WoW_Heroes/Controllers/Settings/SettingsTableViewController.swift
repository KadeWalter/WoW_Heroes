//
//  SettingsTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/10/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var tableModel: [SettingsTableModel] = []
    
    init() {
        super.init(style: .grouped)
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.title = "Settings"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTableModel()
    }
    
    private func buildTableModel() {
        tableModel.append(SettingsTableModel(row: .AppTheme, rowTitle: "App Theme"))
    }
}

// MARK: - TableView Delegate and DataSource Functions
extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableModel[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SettingsOptionCell")
        cell.textLabel?.text = row.rowTitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = tableModel[indexPath.row].row
        switch row {
        case .AppTheme:
            break
        }
    }
}

// MARK: Settings Table Model
extension SettingsTableViewController {
    struct SettingsTableModel {
        var row: RowType
        var rowTitle: String
    }
    
    enum RowType: Int {
        case AppTheme
    }
}
