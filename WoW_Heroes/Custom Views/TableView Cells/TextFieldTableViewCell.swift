//
//  WHTextFieldTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/26/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate: AnyObject {
    func didEndEditing(cell: TextFieldTableViewCell, text: String)
}

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    static let identifier = String(describing: TextFieldTableViewCell.self)
    
    lazy var textField = lazyTextField()
    weak var textFieldDelegate: TextFieldTableViewCellDelegate?
    var rowIdentifier: String?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        initializeView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldDelegate?.didEndEditing(cell: self, text: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        textFieldDelegate?.didEndEditing(cell: self, text: textField.text ?? "")
        return true
    }
    
    @objc func textChanged(textField: UITextField) {
        textFieldDelegate?.didEndEditing(cell: self, text: textField.text ?? "")
    }
    
    private func lazyTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.returnKeyType = .done
        textField.isUserInteractionEnabled = false
        textField.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
        return textField
    }
    
    private func initializeView() {
        contentView.addSubview(textField)
        
        let guide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: guide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
        
        contentView.bringSubviewToFront(textField)
    }
}
