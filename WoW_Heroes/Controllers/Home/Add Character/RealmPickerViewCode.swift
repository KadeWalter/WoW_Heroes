//
//  RealmPickerViewCode.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 6/20/21.
//  Copyright © 2021 Kade Walter. All rights reserved.
//

// THIS IS JUST A PLACE TO STORE WORK DONE WITH THE PICKERVIEW FOR REALM SELECT.
// THIS WAS DONE BEFORE THE CURRENT IMPLEMENTATION, BUT I WANT TO KEEP THIS CODE AROUND.
// -----------------------------------------------------------------------------------------

// MARK: - Realm PickerView Functions:
//extension AddCharacterTableViewController: RealmPickerViewValueUpdatedDelegate {
//    func pickerValueUpdated(indexPath: IndexPath, value: Realm) {
//        selectedRealm = value
//        updateRealmNameTextField(indexPath: indexPath, text: value.name)
//    }
//
//    private func updateRealmNameTextField(indexPath: IndexPath, text: String) {
//        tableModel[indexPath.row].textValue = text
//        tableView.beginUpdates()
//        DispatchQueue.main.async {
//            self.tableView.reloadRows(at: [indexPath], with: .none)
//        }
//        tableView.endUpdates()
//    }
//
//    private func showOrHideRealmPickerView(indexPath: IndexPath) {
//        // IndexPath is the index path for the realm text field cell.
//        tableView.beginUpdates()
//        if tableModel.indices.contains(indexPath.row + 1), tableModel[indexPath.row + 1].rowType == .RealmPicker {
//            // If the realm picker view is visible, remove it.
//            tableModel.remove(at: indexPath.row + 1)
//            tableView.deleteRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
//        } else {
//            // Otherwise add the realm picker view to the tableModel
//            tableModel.insert(AddCharacterTableModelRows(placeholder: nil, rowType: .RealmPicker, rowIdentifier: nil), at: indexPath.row + 1)
//            tableView.insertRows(at: [IndexPath(row: indexPath.row + 1, section: indexPath.section)], with: .fade)
//        }
//        tableView.endUpdates()
//        tableView.reloadData()
//    }
//}

// MARK: - CELL FOR ROW AT:
//            if let cell = tableView.dequeueReusableCell(withIdentifier: RealmSelectPickerViewTableViewCell.identifier, for: indexPath) as? RealmSelectPickerViewTableViewCell {
//                cell.updateCell(indexPath: IndexPath(row: indexPath.row - 1, section: indexPath.section), realmList: realms)
//                cell.realmPickerDelegate = self
//                return cell
//            }

// MARK: DID SELECT:
//        // Editing the name text field
//        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell, cell.rowIdentifier == RowIdentifiers.Name.rawValue {
//            if !cell.textField.isFirstResponder {
//                cell.textField.isUserInteractionEnabled = true
//                cell.textField.becomeFirstResponder()
//            }
//        }
//        if let cell = tableView.cellForRow(at: indexPath), cell.reuseIdentifier == RowIdentifiers.Realm.rawValue {
//            let vc = RealmSelectionTableViewController(withRealms: self.realms)
//            vc.realmSelectionDelegate = self
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        // Select a realm
//        if let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell, cell.rowIdentifier == RowIdentifiers.Realm.rawValue {
//            showOrHideRealmPickerView(indexPath: indexPath)
//        }
