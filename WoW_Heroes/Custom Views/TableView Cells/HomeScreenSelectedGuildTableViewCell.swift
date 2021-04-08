//
//  HomeScreenSelectedGuildTableViewCell.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 1/24/21.
//  Copyright © 2021 Kade Walter. All rights reserved.
//

import UIKit

class HomeScreenSelectedGuildTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: HomeScreenSelectedGuildTableViewCell.self)
    
    // Labels
    private lazy var nameLabel = lazyGuildNameLabel()
    private lazy var memberCountLabel = lazyLabel()
    
    // StackView
    private lazy var stackView = lazyStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initializeViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(guild: Guild, count: Int) {
        nameLabel.text = String(format: "<%@-%@>", guild.name, guild.realm.name)
        if !(count == 0) {
            memberCountLabel.text = String(format: "Member Count: %d", count)
        } else {
            memberCountLabel.text = "Visit the guild roster page to update the guild member count."
        }
    }
    
    private func initializeViews() {
        let guide = contentView.layoutMarginsGuide
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(memberCountLabel)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: guide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
        ])
    }
}

extension HomeScreenSelectedGuildTableViewCell {
    private func lazyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(14.0)
        label.numberOfLines = 1
        return label
    }
    
    private func lazyGuildNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.font = label.font.withSize(21.0)
        label.numberOfLines = 1
        return label
    }
    
    private func lazyStackView() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 3
        return stack
    }
}
