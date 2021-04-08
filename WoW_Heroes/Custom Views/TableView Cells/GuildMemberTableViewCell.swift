//
//  GuildMemberTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class GuildMemberTableViewCell: UITableViewCell {

    static let identifier = String(describing: GuildMemberTableViewCell.self)

    private lazy var nameLabel = lazyLabel()
    private lazy var classLabel = lazyLabel()
    private lazy var levelLabel = lazyLabel()
    private lazy var rankLabel = lazyLabel()
    private lazy var stackView = lazyStackView()
    private lazy var classRankLevelStackView = lazyClassRankLevelStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(withName name: String, rank: Int16, charClass: Classes, level: Int16) {
        nameLabel.text = name
        nameLabel.font = nameLabel.font.withSize(14.0)
        
        if rank == 0 {
            rankLabel.text = localizedGuildMaster()
        } else {
            rankLabel.text = String(format: "%@ %d", localizedRank(), rank + 1)
        }
        rankLabel.font = rankLabel.font.withSize(14.0)
        rankLabel.textAlignment = .center
        
        classLabel.text = charClass.rawValue
        classLabel.textColor = CharacterClass.getColor(forClass: charClass)
        classLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        
        levelLabel.text = String(describing: level)
        levelLabel.font = levelLabel.font.withSize(14.0)
        levelLabel.textAlignment = .right
        
        layoutIfNeeded()
    }

    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        classRankLevelStackView.addArrangedSubview(classLabel)
        classRankLevelStackView.addArrangedSubview(rankLabel)
        classRankLevelStackView.addArrangedSubview(levelLabel)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(classRankLevelStackView)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            classLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            levelLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            classRankLevelStackView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.60),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            classLabel.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.25),
            rankLabel.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.25)
        ])
    }
}

extension GuildMemberTableViewCell {
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
        stack.spacing = 5
        return stack
    }
    
    private func lazyClassRankLevelStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }
    
    private func localizedGuildMaster() -> String {
        return NSLocalizedString("Guild Master", tableName: "Guild", bundle: .main, value: "guild master", comment: "guild master")
    }
    
    private func localizedRank() -> String {
        return NSLocalizedString("Rank", tableName: "Guild", bundle: .main, value: "rank", comment: "rank")
    }
}
