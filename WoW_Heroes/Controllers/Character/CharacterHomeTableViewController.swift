//
//  CharacterTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/15/21.
//  Copyright © 2021 Kade Walter. All rights reserved.
//

import UIKit

class CharacterHomeTableViewController: UITableViewController {
    
    private var character: Character?
    private var loadingMask: LoadingSpinnerViewController?
    private var tableModel: [CharacterHomeTableModel] = []
    
    init() {
        super.init(style: .grouped)
        self.title = localizedCharacter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingMask = LoadingSpinnerViewController(withViewController: self)
        tableView.register(SelectedCharacterTableViewCell.self, forCellReuseIdentifier: SelectedCharacterTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.character = Character.fetchSelectedCharacter()
        self.navigationItem.title = character?.name
        buildTableModel()
    }
    
    private func buildTableModel() {
        tableModel.removeAll()
        guard let _ = character else { return }
        
        tableModel.append(CharacterHomeTableModel(section: .characterOverview, rows: [Rows(rowTitle: "", rowType: .characterOverview)]))
        tableModel.append(CharacterHomeTableModel(section: .informationSelection, rows: buildRowsForInformationSelection()))
    }
}

// MARK: - TableView DataSource and Delegate Functions
extension CharacterHomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = tableModel[indexPath.section].rows[indexPath.row].rowType
        switch rowType {
        case .characterOverview:
            if let cell = tableView.dequeueReusableCell(withIdentifier: SelectedCharacterTableViewCell.identifier) as? SelectedCharacterTableViewCell, let character = character {
                cell.updateCell(forCharacter: character)
                return cell
            }
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "infoCell")
            cell.textLabel?.text = tableModel[indexPath.section].rows[indexPath.row].rowTitle
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = tableModel[indexPath.section].rows[indexPath.row].rowType
        tableView.deselectRow(at: indexPath, animated: true)
        switch rowType {
        case .equippedItems:
            // Go to equipped items screen.
            return
        case .stats:
            // Go to stats screen.
            return
        case .soulbinds:
            // Go to soulbinds screen.
            return
        case .professions:
            // Go to professions screen.
            return
        default:
            return
        }
    }
}

// MARK: - Table Model Information
extension CharacterHomeTableViewController {
    struct CharacterHomeTableModel {
        var section: SectionType
        var rows: [Rows]
    }
    
    struct Rows {
        var rowTitle: String
        var rowType: RowType
    }
    
    enum SectionType: Int {
        case characterOverview
        case informationSelection
    }
    
    enum RowType: Int {
        case characterOverview
        case equippedItems
        case stats
        case soulbinds
        case professions
    }
    
    private func buildRowsForInformationSelection() -> [Rows] {
        var rows: [Rows] = []
        rows.append(Rows(rowTitle: localizedEquippedItems(), rowType: .equippedItems))
        rows.append(Rows(rowTitle: localizedStatistics(), rowType: .stats))
        rows.append(Rows(rowTitle: localizedSoulbinds(), rowType: .soulbinds))
        rows.append(Rows(rowTitle: localizedProfessions(), rowType: .professions))
        return rows
    }
}

// MARK: - Localized Strings
extension CharacterHomeTableViewController {
    private func localizedCharacter() -> String {
        return NSLocalizedString("Character", tableName: "CharacterHome", bundle: .main, value: "equipped items", comment: "equipped items")
    }
    
    private func localizedEquippedItems() -> String {
        return NSLocalizedString("Equipped Items", tableName: "CharacterHome", bundle: .main, value: "equipped items", comment: "equipped items")
    }
    
    private func localizedStatistics() -> String {
        return NSLocalizedString("Statistics", tableName: "CharacterHome", bundle: .main, value: "stats", comment: "stats")
    }
    
    private func localizedSoulbinds() -> String {
        return NSLocalizedString("Soulbinds", tableName: "CharacterHome", bundle: .main, value: "soulbinds", comment: "soulbinds")
    }
    
    private func localizedProfessions() -> String {
        return NSLocalizedString("Professions", tableName: "CharacterHome", bundle: .main, value: "professions", comment: "professions")
    }
}
