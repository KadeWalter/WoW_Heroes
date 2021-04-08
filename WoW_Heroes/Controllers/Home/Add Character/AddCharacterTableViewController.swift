//
//  AddCharacterTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/26/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

protocol CharacterAddedDelegate: class {
    func characterAdded()
}

class AddCharacterTableViewController: UITableViewController {
    
    weak var addCharacterDelegate: CharacterAddedDelegate?
    private var tableModel: [AddCharacterTableModelRows]
    private let region: String
    private var realms: [Realm] = []
    private var characterName: String?
    private var selectedRealm: Realm?
    private var loadingMask: LoadingSpinnerViewController?
    
    init(region: String) {
        self.tableModel = []
        self.region = region
        super.init(style: .grouped)
        self.loadingMask = LoadingSpinnerViewController(withViewController: self)
        self.title = localizedTitle()
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
        tableView.register(RealmSelectPickerViewTableViewCell.self, forCellReuseIdentifier: RealmSelectPickerViewTableViewCell.identifier)
        initializeViews()
        buildTableModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRealms()
    }
    
    private func buildTableModel() {
        // Add the name text field row to the table model
        tableModel.append(AddCharacterTableModelRows(placeholder: localizedNamePlaceholder(), rowType: .Name, rowIdentifier: .Name))
        // Add the realm text field and realm picker rows to the table model
        tableModel.append(AddCharacterTableModelRows(placeholder: localizedRealmPlaceholder(), rowType: .Realm, rowIdentifier: .Realm))
    }
    
    private func getRealms() {
        let refreshDate : Date = UserDefaultsHelper.getDateValue(forKey: "\(udRealmRefreshDate)\(region)") ?? Date()
        if refreshDate <= Date() {
            loadingMask?.showLoadingMask()
            SCPlayableClassees.getClasses(region: region) { success in
                if success {
                    SCRealmIndex.getRealms(region: self.region) { success in
                        if success {
                            self.realms = Realm.fetchAllRealms(forRegion: self.region)
                            self.loadingMask?.hideLoadingMask()
                        } else {
                            self.loadingMask?.hideLoadingMask() {
                                self.showErrorGettingDataAlert()
                            }
                        }
                    }
                } else {
                    self.loadingMask?.hideLoadingMask() {
                        self.showErrorGettingDataAlert()
                    }
                }
            }
        } else {
            realms = Realm.fetchAllRealms(forRegion: region)
        }
    }
    
    @objc private func saveCharacter() {
        // Save character if there is a valid name and realm selected.
        if let realm = selectedRealm, let name = characterName?.trimmingCharacters(in: .whitespacesAndNewlines), name.containsOnlyLettersAndWhitespace() {
            loadingMask?.showLoadingMask()
            // Make the service call to get the character.
            SCCharacterProfile.getCharacter(region: self.region, characterName: name, realm: realm, completion: { success in
                self.loadingMask?.hideLoadingMask() {
                    self.handleGetCharacterCallFinished(success: success)
                }
            })
        } else {
            // Otherwise tell them to fix their stuff.
            let alert = UIAlertController(title: localizedError(), message: localizedCharacterEntryError(), preferredStyle: .alert)
            alert.addOkayButton()
            alert.presentAlert(forViewController: self)
        }
    }
    
    private func handleGetCharacterCallFinished(success: Bool) {
        // This function will likely be on a background thread as it is being called from a completion handler.
        if success {
            // Call delegate so the homescreen can update. Then pop to the homescreen
            addCharacterDelegate?.characterAdded()
            navigationController?.popToRootViewController(animated: true)
        } else {
            // If something bad happened getting character info, tell the user.
            let alert = UIAlertController(title: localizedError(), message: localizedCharacterRetrievalError(), preferredStyle: .alert)
            alert.addOkayButton()
            alert.presentAlert(forViewController: self)
        }
    }
    
    private func showErrorGettingDataAlert() {
        let alert = UIAlertController(title: self.localizedError(), message: localizedRealmRetrievalError(), preferredStyle: .alert)
        alert.addOkayButton()
        alert.presentAlert(forViewController: self)
    }
}

// MARK: - Text Field Delegate Functions
extension AddCharacterTableViewController: TextFieldTableViewCellDelegate {
    func didEndEditing(cell: TextFieldTableViewCell, text: String) {
        if cell.rowIdentifier == RowIdentifiers.Name.rawValue {
            characterName = text
        }
    }
}

// MARK: - Realm PickerView Functions
extension AddCharacterTableViewController: RealmPickerViewValueUpdatedDelegate {
    func pickerValueUpdated(indexPath: IndexPath, value: Realm) {
        selectedRealm = value
        updateRealmNameTextField(indexPath: indexPath, text: value.name)
    }
    
    private func updateRealmNameTextField(indexPath: IndexPath, text: String) {
        tableModel[indexPath.row].textValue = text
        tableView.beginUpdates()
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        tableView.endUpdates()
    }
    
    private func showOrHideRealmPickerView(indexPath: IndexPath) {
        // IndexPath is the index path for the realm text field cell.
        tableView.beginUpdates()
        if tableModel.indices.contains(indexPath.row + 1), tableModel[indexPath.row + 1].rowType == .RealmPicker {
            // If the realm picker view is visible, remove it.
            tableModel.remove(at: indexPath.row + 1)
            tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
        } else {
            // Otherwise add the realm picker view to the tableModel
            tableModel.insert(AddCharacterTableModelRows(placeholder: nil, rowType: .RealmPicker, rowIdentifier: nil), at: indexPath.row + 1)
            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
        }
        tableView.endUpdates()
        tableView.reloadData()
    }
}

// MARK: - Table View Delegate and Data Source Functions
extension AddCharacterTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = tableModel[indexPath.row]
        switch cellInfo.rowType {
        case .Name, .Realm:
            if let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath) as? TextFieldTableViewCell {
                cell.textField.placeholder = cellInfo.placeholder
                cell.textFieldDelegate = self
                cell.rowIdentifier = cellInfo.rowIdentifier?.rawValue
                if let text = cellInfo.textValue {
                    cell.textField.text = text
                }
                cell.selectionStyle = .none
                return cell
            }
        case .RealmPicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: RealmSelectPickerViewTableViewCell.identifier, for: indexPath) as? RealmSelectPickerViewTableViewCell {
                cell.updateCell(indexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section), realmList: realms)
                cell.realmPickerDelegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.resignFirstResponder()
        // Editing the name text field
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell, cell.rowIdentifier == RowIdentifiers.Name.rawValue {
            if !cell.textField.isFirstResponder {
                cell.textField.isUserInteractionEnabled = true
                cell.textField.becomeFirstResponder()
            }
        }
        // Select a realm
        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell, cell.rowIdentifier == RowIdentifiers.Realm.rawValue {
            showOrHideRealmPickerView(indexPath: indexPath)
        }
    }
}

// MARK: - Add Character Table Model
extension AddCharacterTableViewController {
    private struct AddCharacterTableModelRows {
        var placeholder: String?
        var textValue: String?
        var rowType: RowTypes
        var rowIdentifier: RowIdentifiers?
    }
    
    private enum RowTypes: Int {
        case Name = 0
        case Realm
        case RealmPicker
    }
    
    private enum RowIdentifiers: String {
        case Name = "NameRow"
        case Realm = "RealmRow"
    }
}

// MARK: - View Setup
extension AddCharacterTableViewController {
    private func initializeViews() {
        // Save Button
        let saveButton = UIBarButtonItem(title: localizedSave(), style: .done, target: self, action: #selector(saveCharacter))
        self.navigationItem.rightBarButtonItem = saveButton
    }
}

// MARK: - Localized Strings
extension AddCharacterTableViewController {
    private func localizedTitle() -> String {
        return NSLocalizedString("Add Character Title", tableName: "AddCharacter", bundle: .main, value: "add character title", comment: "add character title")
    }
    
    private func localizedNamePlaceholder() -> String {
        return NSLocalizedString("Name Placeholder", tableName: "AddCharacter", bundle: .main, value: "name placeholder", comment: "name placeholder")
    }
    
    private func localizedRealmPlaceholder() -> String {
        return NSLocalizedString("Realm Placeholder", tableName: "AddCharacter", bundle: .main, value: "realm placeholder", comment: "realm placeholder")
    }
    
    private func localizedSave() -> String {
        return NSLocalizedString("Save", tableName: "GlobalStrings", bundle: .main, value: "save button title", comment: "save button title")
    }
    
    private func localizedError() -> String {
        return NSLocalizedString("Error", tableName: "GlobalStrings", bundle: .main, value: "error title", comment: "error title")
    }
    
    private func localizedCharacterEntryError() -> String {
        return NSLocalizedString("Character Entry Error", tableName: "AddCharacter", bundle: .main, value: "character entry error message", comment: "character entry error message")
    }
    
    private func localizedCharacterRetrievalError() -> String {
        return NSLocalizedString("Character Retrieval Error", tableName: "AddCharacter", bundle: .main, value: "character retrieval error message", comment: "character retrieval error message")
    }
    
    private func localizedRealmRetrievalError() -> String {
        return NSLocalizedString("Realm Retrieval Error", tableName: "AddCharacter", bundle: .main, value: "realm retrieval error message", comment: "realm retrieval error message")
    }
}
