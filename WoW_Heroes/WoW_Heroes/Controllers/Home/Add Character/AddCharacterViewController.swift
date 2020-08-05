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
    
//    var realms: [Realm] = []
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(realmsRetrieved(notif:)), name: .didRetrieveRealmList, object: nil)
        SCRealmIndex.getRealms(region: self.region)
    }
    
    @objc func realmsRetrieved(notif: Notification) {
        NotificationCenter.default.removeObserver(self, name: .didRetrieveRealmList, object: nil)
        // Fetch the realms for core data and store them alphabetically:
        
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
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
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
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([flexBarButton, doneButton], animated: true)
        
        // Assign picker view and toolbar to text field.
        realmTextField.inputView = realmPicker
        realmTextField.inputAccessoryView = toolbar
    }
}
