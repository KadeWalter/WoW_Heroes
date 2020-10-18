//
//  GuildEventTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/16/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class GuildEventTableViewCell: UITableViewCell {

    static let identifier = String(describing: GuildEventTableViewCell.self)

    lazy var messageLabel = lazyMessageLabel()
    lazy var eventLabel = lazyEventLabel()
    lazy var stackView = lazyStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCellAsAchievement(forCharacter characterName: String, achievementName: String) {
        messageLabel.text = localizedAchievementMessage(characterName: characterName)
        
        eventLabel.text = "[\(achievementName)]"
        eventLabel.textColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor(hex: achievementDarkModeYellowHex) : UIColor(hex: achievementLightModeYellowHex)
        
        layoutIfNeeded()
    }
    
    func updateCellAsEncounter(forGuild guildName: String, encounterName: String, difficulty: String) {
        messageLabel.text = localizedEncounterMessage(guildName: guildName)
        
        eventLabel.text = String(format: "[%@: %@]", difficulty, encounterName)
        eventLabel.textColor = UIColor(hex: encounterRedHex)
        layoutIfNeeded()
    }

    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(eventLabel)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            eventLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor)
        ])
    }
}

extension GuildEventTableViewCell {
    private func lazyMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.font = label.font.withSize(14.0)
        return label
    }
    
    private func lazyEventLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.font = label.font.withSize(14.0)
        return label
    }
    
    private func lazyStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 3
        return stack
    }
    
    private func localizedAchievementMessage(characterName: String) -> String {
        let message = NSLocalizedString("Achievement Message", tableName: "Guild", bundle: .main, value: "achievement earned", comment: "achievement earned")
        return String(format: message, characterName)
    }
    
    private func localizedEncounterMessage(guildName: String) -> String {
        let message = NSLocalizedString("Encounter Message", tableName: "Guild", bundle: .main, value: "encounter defeated", comment: "encounter defeated")
        return String(format: message, guildName)
    }
    
}
