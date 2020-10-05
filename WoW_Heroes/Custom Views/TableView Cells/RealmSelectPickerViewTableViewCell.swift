//
//  WHPickerViewTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/26/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

protocol RealmPickerViewValueUpdatedDelegate: class {
    func pickerValueUpdated(indexPath: IndexPath, value: Realm)
}

class RealmSelectPickerViewTableViewCell: UITableViewCell {

    static let identifier = String(describing: RealmSelectPickerViewTableViewCell.self)
    
    weak var realmPickerDelegate: RealmPickerViewValueUpdatedDelegate?
    lazy var pickerView = lazyPickerView()
    var realms: [Realm] = []
    var indexPath: IndexPath? // IndexPath for the realm text field cell
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(indexPath: IndexPath, realmList: [Realm]) {
        realms = realmList
        self.indexPath = indexPath
        if let startRealm = realmList.first {
            setSelectedRealm(realm: startRealm)
        }
        pickerView.reloadAllComponents()
    }
    
    private func setSelectedRealm(realm: Realm) {
        if let ip = indexPath {
            realmPickerDelegate?.pickerValueUpdated(indexPath: ip, value: realm)
        }
    }
}

// MARK: - PickerView Delegate and Data Source Functions
extension RealmSelectPickerViewTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
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
        setSelectedRealm(realm: realms[row])
    }
}

// MARK: - View Setup
extension RealmSelectPickerViewTableViewCell {
    private func initializeViews() {
        contentView.addSubview(pickerView)
        
        let guide = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: guide.topAnchor),
            pickerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            pickerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
    
    private func lazyPickerView() -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }
}
