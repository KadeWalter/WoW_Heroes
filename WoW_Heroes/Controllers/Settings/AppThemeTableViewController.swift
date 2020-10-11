//
//  AppThemeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/10/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class AppThemeTableViewController: UITableViewController {
    
    private var tableModel: [AppThemeTableModel] = []
    private var colorInUserDefaults: String
    
    init() {
        colorInUserDefaults = UserDefaultsHelper.getStringValue(forKey: udAppTheme) ?? ""
        super.init(style: .grouped)
        self.title = localizedAppTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTableModel()
    }
    
    private func updateColorVariables(forHex hex: String, indexPath: IndexPath) {
        UserDefaultsHelper.set(value: hex, forKey: udAppTheme)
        colorInUserDefaults = hex
        var count = 0
        for row in tableModel {
            tableModel[count].selectedRow = colorInUserDefaults == row.rowHex
            count = count + 1
        }
    }
    
    private func updateColorThemes(hex: String) {
        let color = UIColor(hex: hex)
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.setNavColor(color: color)
        self.tabBarController?.tabBar.tintColor = color
    }
    
    func buildTableModel() {
        tableModel.append(AppThemeTableModel(row: .Alliance, rowTitle: localizedAlliance(), rowHex: allianceHex, selectedRow: colorInUserDefaults == allianceHex))
        tableModel.append(AppThemeTableModel(row: .Horde, rowTitle: localizedHorde(), rowHex: hordeHex, selectedRow: colorInUserDefaults == hordeHex))
    }
}

// MARK: TableView Delegate And DataSource Functions
extension AppThemeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableModel[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AppThemeCell")
        cell.textLabel?.text = row.rowTitle
        cell.accessoryType = row.selectedRow ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateColorVariables(forHex: tableModel[indexPath.row].rowHex, indexPath: indexPath)
        updateColorThemes(hex: tableModel[indexPath.row].rowHex)
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return localizedNote()
    }
}

// MARK: - Localized Strings
extension AppThemeTableViewController {
    private func localizedAppTheme() -> String {
        return NSLocalizedString("App Theme Title", tableName: "AppTheme", bundle: .main, value: "app theme title", comment: "app theme title")
    }
    
    private func localizedHorde() -> String {
        return NSLocalizedString("Horde", tableName: "AppTheme", bundle: .main, value: "horde title", comment: "horde title")
    }
    
    private func localizedAlliance() -> String {
        return NSLocalizedString("Alliance", tableName: "AppTheme", bundle: .main, value: "alliance title", comment: "alliance title")
    }
    
    private func localizedNote() -> String {
        return NSLocalizedString("Note", tableName: "AppTheme", bundle: .main, value: "note", comment: "note")
    }
}

// MARK: - Table Model
extension AppThemeTableViewController {
    private struct AppThemeTableModel {
        var row: RowType
        var rowTitle: String
        var rowHex: String
        var selectedRow: Bool
    }
    
    private enum RowType: Int {
        case Alliance
        case Horde
    }
}
