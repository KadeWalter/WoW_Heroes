//
//  OtherCharacterTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/9/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class OtherCharacterTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: OtherCharacterTableViewCell.self)

    lazy var nameLabel = lazyLabel()
    lazy var classLabel = lazyLabel()
    lazy var levelLabel = lazyLabel()
    lazy var stackView = lazyStackView()
    lazy var classLevelStackView = lazyClassLevelStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(withName name: String, realmName: String, charClass: Classes, level: String) {
        nameLabel.text = "\(name) - \(realmName)"
        classLabel.text = charClass.rawValue
        classLabel.textColor = CharacterClass.getColor(forClass: charClass)
        classLabel.font = classLabel.font.withSize(15.0)
        levelLabel.text = level
        
        layoutIfNeeded()
    }

    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        classLevelStackView.addArrangedSubview(classLabel)
        classLevelStackView.addArrangedSubview(levelLabel)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(classLevelStackView)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            classLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            classLevelStackView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.4),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
    }
}

extension OtherCharacterTableViewCell {
    private func lazyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    private func lazyStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }
    
    private func lazyClassLevelStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 5
        return stack
    }
    
}
