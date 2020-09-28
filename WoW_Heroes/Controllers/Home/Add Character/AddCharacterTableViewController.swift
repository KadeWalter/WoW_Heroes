//
//  AddCharacterTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/26/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

protocol CharacterAddedDelegate: class {
    func characterAdded(characterName name: String, realm: Realm)
}

class AddCharacterTableViewController: UITableViewController {
    
    weak var addCharacterDelegate: CharacterAddedDelegate?
    var tableModel: [AddCharacterTableModelRows]
    let region: String
    var realms: [Realm] = []
    var characterName: String?
    var realmName: String?
    var selectedRealm: Realm?
    
    init(region: String) {
        self.tableModel = []
        self.region = region
        super.init(style: .grouped)
        self.title = localizedTitle()
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
        getRealms()
    }
    
    func buildTableModel() {
        // Add the name text field row to the table model
        tableModel.append(AddCharacterTableModelRows(placeholder: localizedNamePlaceholder(), rowType: .Name, rowIdentifier: .Name))
        // Add the realm text field and realm picker rows to the table model
        tableModel.append(AddCharacterTableModelRows(placeholder: localizedRealmPlaceholder(), rowType: .Realm, rowIdentifier: .Realm))
    }
    
    func getRealms() {
        let refreshDate : Date = UserDefaultsHelper.getValue(forKey: "\(realmRefreshDate)\(region)") as? Date ?? Date()
        if refreshDate <= Date() {
            showSpinner(onView: self.view)
            SCRealmIndex.getRealms(region: self.region) { success in
                if success {
                    self.realms = Realm.fetchAllRealms(forRegion: self.region).sorted(by: { $0.name < $1.name })
                    self.removeSpinner()
                }
            }
        } else {
            realms = Realm.fetchAllRealms(forRegion: region).sorted(by: {$0.name < $1.name })
        }
    }
    
    @objc func saveCharacter() {
        // Save character
        if let realm = selectedRealm, let name = characterName {
            addCharacterDelegate?.characterAdded(characterName: name, realm: realm)
            self.navigationController?.popToRootViewController(animated: true)
        }
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
        realmName = value.name
        updateRealmNameTextField(indexPath: indexPath, text: value.name)
    }
    
    func updateRealmNameTextField(indexPath: IndexPath, text: String) {
        tableModel[indexPath.row].textValue = text
        tableView.beginUpdates()
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        tableView.endUpdates()
    }
    
    func showOrHideRealmPickerView(indexPath: IndexPath) {
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
    struct AddCharacterTableModelRows {
        var placeholder: String?
        var textValue: String?
        var rowType: RowTypes
        var rowIdentifier: RowIdentifiers?
    }
    
    enum RowTypes: Int {
        case Name = 0
        case Realm
        case RealmPicker
    }
    
    enum RowIdentifiers: String {
        case Name = "NameRow"
        case Realm = "RealmRow"
    }
}

// MARK: - View Setup
extension AddCharacterTableViewController {
    func initializeViews() {
        // Save Button
        let saveButton = UIBarButtonItem(title: localizedSave(), style: .done, target: self, action: #selector(saveCharacter))
        self.navigationItem.rightBarButtonItem = saveButton
    }
}

// MARK: - Localized Strings
extension AddCharacterTableViewController {
    func localizedTitle() -> String {
        return NSLocalizedString("Add Character Title", tableName: "AddCharacter", bundle: .main, value: "add character title", comment: "add character title")
    }
    
    func localizedNamePlaceholder() -> String {
        return NSLocalizedString("Name Placeholder", tableName: "AddCharacter", bundle: .main, value: "name placeholder", comment: "name placeholder")
    }
    
    func localizedRealmPlaceholder() -> String {
        return NSLocalizedString("Realm Placeholder", tableName: "AddCharacter", bundle: .main, value: "realm placeholder", comment: "realm placeholder")
    }
    
    func localizedSave() -> String {
        return NSLocalizedString("Save", tableName: "GlobalStrings", bundle: .main, value: "save button title", comment: "save button title")
    }
}
