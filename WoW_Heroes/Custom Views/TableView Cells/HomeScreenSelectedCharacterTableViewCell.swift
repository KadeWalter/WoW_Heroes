//
//  HomeScreenSelectedCharacterTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/18/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class HomeScreenSelectedCharacterTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: HomeScreenSelectedCharacterTableViewCell.self)

    // Labels
    private lazy var nameLabel = lazyCharacterNameLabel()
    private lazy var realmLabel = lazyLabel()
    private lazy var levelLabel = lazyLabel()
    private lazy var classLabel = lazyLabel()
    private lazy var raceLabel = lazyLabel()
    private lazy var covenantLabel = lazyLabel()
    private lazy var equippedIlvlLabel = lazyLabel()
    private lazy var achievementPointsLabel = lazyLabel()
    
    // StackViews
    private lazy var stackView = lazyOverallVerticalStack()
    private lazy var topStackView = lazyTopVerticalStack()
    private lazy var bottomStackView = lazyBottomVerticalStack()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(forCharacter character: Character) {
        // Update all the text on the selected character cell
        nameLabel.text = getNameString(characterName: character.name, title: character.activeTitle)
        realmLabel.attributedText = getRealmString(realmName: character.realm.name, faction: character.faction)
        levelLabel.text = String(format: "%@ %d", localizedLevel(), character.level)
        classLabel.attributedText = getClassString(spec: character.activeSpec, className: character.characterClass.name)
        raceLabel.text = String(format: "%@ %@", character.gender, character.race)
        covenantLabel.text = String(format: "%@: Renown %d", character.covenantName, character.renownLevel)
        
        equippedIlvlLabel.text = String(format: "%@: %d", localizedEquippedIlvl(), character.equippedIlvl)
        achievementPointsLabel.text = String(format: "%@: %d", localizedAchievePoints(), character.achievementPoints)
        
        layoutIfNeeded()
    }
    
    private func getNameString(characterName: String, title: String?) -> String {
        var name = ""
        if let title = title, !title.isEmpty {
            name = title.replacingOccurrences(of: "{name}", with: characterName)
        } else {
            name = characterName
        }
        return name
    }
    
    private func getRealmString(realmName: String, faction: String) -> NSMutableAttributedString {
        let realmString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: "%@ - ", realmName))
        let attrs: [NSAttributedString.Key : Any] = [.foregroundColor : faction == "Horde" ? UIColor(hex: hordeHex) : UIColor(hex: allianceHex), .font : UIFont.boldSystemFont(ofSize: 14.0)]
        let factionString: NSMutableAttributedString = NSMutableAttributedString(string: faction, attributes: attrs)
        let combination: NSMutableAttributedString = NSMutableAttributedString()
        combination.append(realmString)
        combination.append(factionString)
        return combination
    }
    
    private func getClassString(spec: String, className: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key : Any] = [.foregroundColor : CharacterClass.getColor(forClass: Classes.getClass(fromClass: className)), .font : UIFont.boldSystemFont(ofSize: 14.0)]
        let classString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: "%@ %@", spec, className), attributes: attrs)
        let combination: NSMutableAttributedString = NSMutableAttributedString()
        combination.append(classString)
        return combination
    }

    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        topStackView.addArrangedSubview(nameLabel)
        topStackView.addArrangedSubview(realmLabel)
        topStackView.addArrangedSubview(levelLabel)
        topStackView.addArrangedSubview(classLabel)
        topStackView.addArrangedSubview(raceLabel)
        topStackView.addArrangedSubview(covenantLabel)
        
        bottomStackView.addArrangedSubview(equippedIlvlLabel)
        bottomStackView.addArrangedSubview(achievementPointsLabel)
        
        stackView.addArrangedSubview(topStackView)
        stackView.addArrangedSubview(bottomStackView)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
}

extension HomeScreenSelectedCharacterTableViewCell {
    private func lazyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(14.0)
        label.numberOfLines = 1
        return label
    }
    
    private func lazyCharacterNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(21.0)
        label.numberOfLines = 1
        return label
    }
    
    private func lazyTopVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 1
        return stack
    }
    
    private func lazyBottomVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 3
        return stack
    }
    
    private func lazyOverallVerticalStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 15
        return stack
    }
    
    private func localizedLevel() -> String {
         return NSLocalizedString("Level", tableName: "Home", bundle: .main, value: "level", comment: "level")
    }
    
    private func localizedEquippedIlvl() -> String {
         return NSLocalizedString("Equipped Ilvl", tableName: "Home", bundle: .main, value: "equipped item level", comment: "equipped item level")
    }
    
    private func localizedAchievePoints() -> String {
         return NSLocalizedString("Achievements Points", tableName: "Home", bundle: .main, value: "achievement points", comment: "achievement points")
    }
}
