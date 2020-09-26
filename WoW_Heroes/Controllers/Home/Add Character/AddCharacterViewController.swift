//
//  AddCharacterViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 3/13/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit
import CoreData

protocol CharacterAddedDelegate: class {
    func characterAdded()
}

class AddCharacterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var realmTextField: UITextField!
    
    var realms: [Realm] = []
    
    weak var addDelegate: CharacterAddedDelegate?
    let region: String
    let realmPicker = UIPickerView()
    var selectedRealm: String?
    
    init(region: String) {
        self.region = region
        super.init(nibName: nil, bundle: nil)
        self.title = "Add A Character"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        getRealms()
    }
}
    
// MARK: - Helper Functions
extension AddCharacterViewController {
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func getRealms() {
        let refreshDate : Date = UserDefaultsHelper.getValue(forKey: realmRefreshDate) as? Date ?? Date()
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
        // TODO: - Add Character Information to core data.
        // Pop view controller
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension AddCharacterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    // TODO: - Get realms from core data and then load them into the picker view.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realms.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return realms[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // TODO: - set selectedRealm to realm in picker
    }
}

// MARK: - Localized Strings
extension AddCharacterViewController {
    // TODO: - Localize any strings used on this screen.
}

// MARK: - Finish view set up.
extension AddCharacterViewController {
    func setUpViews() {
        // Add save button to nav bar.
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveCharacter))
        self.navigationItem.rightBarButtonItem = saveButton
        
        // Set realm tint color to clear to hide the cursor.
        realmTextField.tintColor = .clear
        
        // Create picker view.
        realmPicker.delegate = self
        realmPicker.backgroundColor = .white
        
        // Create tool bar for picker view.
        let toolbar = UIToolbar(frame: CGRect(x:0, y: 0,width:UIScreen.main.bounds.width, height:44))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexBarButton, doneButton], animated: true)
        
        // Assign picker view and toolbar to text field.
        realmTextField.inputView = realmPicker
        realmTextField.inputAccessoryView = toolbar
    }
}
