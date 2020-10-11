//
//  HomeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 1/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    private var tableModel: [HomeTableModel] = []
    var allCharacters: [Character] = []
    var otherCharacters: [Character] = []
    var selectedCharacter: Character?
    var loadingMask: LoadingSpinnerViewController?
    
    init() {
        super.init(style: .grouped)
        let addCharacterButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCharacter))
        addCharacterButton.tintColor = .red
        self.navigationItem.rightBarButtonItem = addCharacterButton
        self.title = localizedHome()
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingMask = LoadingSpinnerViewController(withViewController: self)
        registerTableViewCells()
        buildTableModel()
        
        // REMOVE THIS LATER. USE FOR DEVELOPMENT
        print(UserDefaultsHelper.getValue(forKey: udBlizzardAccessToken) ?? "")
    }
    
    private func buildTableModel() {
        // get the characters from the database and then sort them into the selected character and other characters
        tableModel.removeAll()
        buildCharacterObjects()
        
        if selectedCharacter != nil {
            tableModel.append(HomeTableModel(sectionHeader: "", section: .selectedCharacter, rows: getRows(forSection: .selectedCharacter)))
        }
        if otherCharacters.count > 0 {
            tableModel.append(HomeTableModel(sectionHeader: localizedOtherCharactersHeader(), section: .otherCharacters, rows: getRows(forSection: .otherCharacters)))
        }
        if allCharacters.count > 0 {
            tableModel.append(HomeTableModel(sectionHeader: localizedUpdateHeader(), section: .updateCharacter, rows: getRows(forSection: .updateCharacter)))
        }
        tableView.reloadData()
        if allCharacters.count == 0 {
            addNewCharacter()
        }
    }
    
    private func buildCharacterObjects() {
        // Delete the existing objects in the db
        otherCharacters.removeAll()
        allCharacters = Character.fetchAllCharacters()
        
        // Get the selected character.
        selectedCharacter = allCharacters.filter({ $0.isSelectedCharacter == true }).first
        // If a character wasnt found with the filter, just set the selected character as the first character.
        if selectedCharacter == nil, allCharacters.count > 0 {
                selectedCharacter = allCharacters.first
        }
        
        // Build the array for characters that are not selected.
        for char in allCharacters {
            if char != selectedCharacter {
                otherCharacters.append(char)
            }
        }
    }
}

// MARK: - Add Character Flow
extension HomeTableViewController {
    @objc private func addNewCharacter() {
        
        DispatchQueue.main.async {
            let vc = RegionSelectTableViewController()
            vc.addCharacterDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func deleteCharacter(character: Character) {
        tableView.beginUpdates()
        Character.deleteCharacter(withCharacter: character)
        tableView.endUpdates()
        buildTableModel()
    }
    
    private func finishedUpdatingCharacters(selectedCharacterOnly: Bool, success: Bool) {
        if success {
            buildTableModel()
        } else {
            let alert = UIAlertController(title: localizedError(), message: selectedCharacterOnly ? localizedErrorUpdatingSelectedCharacter() : localizedErrorUpdatingAllCharacters(), preferredStyle: .alert)
            alert.addOkayButton()
            alert.presentAlert(forViewController: self)
        }
    }
}

// MARK: - Added Character Delegate
extension HomeTableViewController: CharacterAddedDelegate {
    func characterAdded() {
        DispatchQueue.main.async {
            self.buildTableModel()
        }
    }
}

// MARK: - Table view data source
extension HomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableModel[section].sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableModel[indexPath.section].rows[indexPath.row]
        switch row {
        case .selectedCharacter:
            if let cell = tableView.dequeueReusableCell(withIdentifier: OtherCharacterTableViewCell.identifier) as? OtherCharacterTableViewCell, let character = selectedCharacter {
                cell.updateCell(withName: character.name, realmName: character.realm.name, charClass: Classes.getClass(fromClass: character.characterClass.name), level: String(describing: character.level))
                return cell
            }
        case .otherCharacter:
            if let cell = tableView.dequeueReusableCell(withIdentifier: OtherCharacterTableViewCell.identifier) as? OtherCharacterTableViewCell {
                let character = otherCharacters[indexPath.row]
                cell.updateCell(withName: character.name, realmName: character.realm.name, charClass: Classes.getClass(fromClass: character.characterClass.name), level: String(describing: character.level))
                return cell
            }
        case .updateAllCharacters:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "UpdateAllCharactersCell")
            cell.textLabel?.text = localizedUpdateAllCharacters()
            return cell
        case .updateSelectedCharacter:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "UpdateCharacterCell")
            cell.textLabel?.text = localizedUpdateCharacter()
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = tableModel[indexPath.section].section
        switch section {
        case .selectedCharacter:
            break
        case .otherCharacters:
            // set the character that corresponds to the selected row as the selected character
            // if the selected character currently exists, swap to the new one.
            // otherwise just assign the character
            if let previous = selectedCharacter {
                Character.setIsSelected(forCharacters: [previous], isSelected: false)
                selectedCharacter = otherCharacters[indexPath.row]
                Character.setIsSelected(forCharacters: [otherCharacters[indexPath.row]], isSelected: true)
            } else {
                selectedCharacter = otherCharacters[indexPath.row]
                Character.setIsSelected(forCharacters: [otherCharacters[indexPath.row]], isSelected: true)
            }
            // Reload the home screen when selected character changes.
            buildTableModel()
        case .updateCharacter:
            let row = tableModel[indexPath.section].rows[indexPath.row]
            if row == .updateSelectedCharacter, let char = selectedCharacter {
                loadingMask?.showLoadingMask()
                // call the character service call once for the selected character
                SCCharacterProfile.getCharacter(region: char.realm.region, characterName: char.name, realm: char.realm) { success in
                    self.loadingMask?.hideLoadingMask() {
                        self.finishedUpdatingCharacters(selectedCharacterOnly: true, success: success)
                    }
                }
            } else if row == .updateAllCharacters {
                // Count how many characters we call to update.
                var count = 0
                if allCharacters.count > 0 {
                    loadingMask?.showLoadingMask()
                }
                for char in allCharacters {
                    count = count + 1
                    SCCharacterProfile.getCharacter(region: char.realm.region, characterName: char.name, realm: char.realm) { success in
                        count = count - 1
                        // When the count hits 0, we are done and can update the table
                        if count == 0 {
                            self.loadingMask?.hideLoadingMask() {
                                self.finishedUpdatingCharacters(selectedCharacterOnly: false, success: success)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = tableModel[indexPath.section].section
        switch section {
        case .otherCharacters:
            return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let section = tableModel[indexPath.section].section
            switch section {
            case .otherCharacters:
                deleteCharacter(character: otherCharacters[indexPath.row])
            default:
                break
            }
        default:
            break
        }
    }
    
    private func registerTableViewCells() {
        tableView.register(OtherCharacterTableViewCell.self, forCellReuseIdentifier: OtherCharacterTableViewCell.identifier)
    }
}

extension HomeTableViewController {
    private struct HomeTableModel {
        var sectionHeader: String
        var section: SectionType
        var rows: [RowType]
    }
    
    private enum SectionType: Int {
        case selectedCharacter
        case otherCharacters
        case updateCharacter
    }
    
    private enum RowType: Int {
        case selectedCharacter
        case otherCharacter
        case updateSelectedCharacter
        case updateAllCharacters
    }
    
    private func getRows(forSection section: SectionType) -> [RowType] {
        var rows: [RowType] = []
        switch section {
        case .selectedCharacter:
            rows = getRowsForSelectedCharacter()
        case .otherCharacters:
            rows = getRowsForOtherCharacters()
        case .updateCharacter:
            rows = getRowsForUpdateData()
        }
        return rows
    }
    
    private func getRowsForSelectedCharacter() -> [RowType] {
        if selectedCharacter != nil {
            return [.selectedCharacter]
        }
        return []
    }
    
    private func getRowsForOtherCharacters() -> [RowType] {
        var rows: [RowType] = []
        for _ in otherCharacters {
            rows.append(.otherCharacter)
        }
        return rows
    }
    
    private func getRowsForUpdateData() -> [RowType] {
        var rows: [RowType] = [.updateSelectedCharacter]
        if otherCharacters.count > 0 {
            rows.append(.updateAllCharacters)
        }
        return rows
    }
}

// MARK: - Localized Strings
extension HomeTableViewController {
    private func localizedHome() -> String {
        return NSLocalizedString("Home Screen Title", tableName: "Home", bundle: .main, value: "home screen title", comment: "home screen title")
    }
    
    private func localizedOtherCharactersHeader() -> String {
        return NSLocalizedString("Other Characters", tableName: "Home", bundle: .main, value: "other characters", comment: "other characters")
    }
    
    private func localizedUpdateHeader() -> String {
        return NSLocalizedString("Update Character Info", tableName: "Home", bundle: .main, value: "update info", comment: "update info")
    }
    
    private func localizedUpdateAllCharacters() -> String {
        return NSLocalizedString("Update All Characters", tableName: "Home", bundle: .main, value: "update all characters", comment: "update all characters")
    }
    
    private func localizedUpdateCharacter() -> String {
        return NSLocalizedString("Update Selected Character", tableName: "Home", bundle: .main, value: "update character", comment: "update character")
    }
    
    private func localizedError() -> String {
        return NSLocalizedString("Error", tableName: "GlobalStrings", bundle: .main, value: "error", comment: "error")
    }
    
    private func localizedErrorUpdatingSelectedCharacter() -> String {
        return NSLocalizedString("Error Updating Selected Character", tableName: "Home", bundle: .main, value: "error updating selected character", comment: "error updating selected character")
    }
    
    private func localizedErrorUpdatingAllCharacters() -> String {
        return NSLocalizedString("Error Updating All Characters", tableName: "Home", bundle: .main, value: "error updating all characters", comment: "error updating all characters")
    }
}
