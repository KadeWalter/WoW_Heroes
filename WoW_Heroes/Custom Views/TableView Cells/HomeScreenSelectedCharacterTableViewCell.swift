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
    lazy var nameLabel = lazyCharacterNameLabel()
    lazy var guildLabel = lazyGuildLabel()
    lazy var levelClassLabel = lazyLabel()
    lazy var raceLabel = lazyLabel()
    lazy var equippedIlvlLabel = lazyLabel()
    lazy var achievementPointsLabel = lazyLabel()
    lazy var realmLabel = lazyLabel()
    
    // StackViews
    lazy var stackView = lazyOverallVerticalStack()
    lazy var topStackView = lazyTopVerticalStack()
    lazy var bottomStackView = lazyBottomVerticalStack()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(forCharacter character: Character) {
        nameLabel.text = getNameString(characterName: character.name, title: character.activeTitle)
        guildLabel.text = getGuildString(guildName: character.guild?.name)
        realmLabel.attributedText = getRealmString(realmName: character.realm.name, faction: character.faction)
        levelClassLabel.attributedText = getClassString(level: character.level, spec: character.activeSpec, className: character.characterClass.name)
        raceLabel.text = String(format: "%@ %@", character.gender, character.race)
        equippedIlvlLabel.text = String(format: "%@: %d", localizedEquippedIlvl(), character.equippedIlvl)
        achievementPointsLabel.text = String(format: "%@: %d", localizedAchievePoints(), character.achievementPoints)
        
        layoutIfNeeded()
    }
    
    private func getGuildString(guildName: String?) -> String {
        var guild = ""
        if let guildName = guildName, !guildName.isEmpty {
            guild = "<\(guildName)>"
        }
        return guild
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
    
    private func getClassString(level: Int16, spec: String, className: String) -> NSMutableAttributedString {
        let levelString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: "%@ %d ", localizedLevel(), level))
        let attrs: [NSAttributedString.Key : Any] = [.foregroundColor : CharacterClass.getColor(forClass: Classes.getClass(fromClass: className)), .font : UIFont.boldSystemFont(ofSize: 14.0)]
        let classString: NSMutableAttributedString = NSMutableAttributedString(string: String(format: "%@ %@", spec, className), attributes: attrs)
        let combination: NSMutableAttributedString = NSMutableAttributedString()
        combination.append(levelString)
        combination.append(classString)
        return combination
    }

    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        topStackView.addArrangedSubview(nameLabel)
//        if let guildText = guildLabel.text, !guildText.isEmpty {
            topStackView.addArrangedSubview(guildLabel)
//        }
        topStackView.addArrangedSubview(realmLabel)
        topStackView.addArrangedSubview(levelClassLabel)
        topStackView.addArrangedSubview(raceLabel)
        
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
        label.font = label.font.withSize(20.0)
        label.numberOfLines = 1
        return label
    }
    
    private func lazyGuildLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(18.0)
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
