//
//  GuildRosterTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class GuildRosterTableViewController: UITableViewController {
    
    // TODO: ADD Pull to refresh to update the roster
    
    private var tableModel: [RosterTableModel] = []
    var guild: Guild
    var guildRoster: [GuildRosterMember]?
    var loadingMask: LoadingSpinnerViewController?
    
    init(withTitle title: String, guild: Guild) {
        self.guild = guild
        super.init(style: .grouped)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingMask = LoadingSpinnerViewController(withViewController: self)
        tableView.register(GuildMemberTableViewCell.self, forCellReuseIdentifier: GuildMemberTableViewCell.identifier)
        getRosterInformation()
        buildTableModel()
    }
    
    private func getRosterInformation() {
        // try to fetch the roster for the guild from core data
        guildRoster = GuildRosterMember.fetchGuildMembers(withGuildId: guild.id, guildName: guild.name)
        // if it returns 0 results, we need to fetch for a new roster. otherwise build the table model.
        if guildRoster?.count == 0 {
            loadingMask?.showLoadingMask()
            SCGuildRoster.getRoster(region: guild.realm.region, guildSlug: guild.slug, realmSlug: guild.realm.slug) { success in
                if success {
                    self.guildRoster = GuildRosterMember.fetchGuildMembers(withGuildId: self.guild.id, guildName: self.guild.name)
                    self.loadingMask?.hideLoadingMask() {
                        self.buildTableModel()
                    }
                } else {
                    self.loadingMask?.hideLoadingMask() {
                        let alert = UIAlertController(title: self.localizedError(), message: self.localizedErrorRetrievingMessage(), preferredStyle: .alert)
                        alert.addOkayButton()
                        alert.presentAlert(forViewController: self)
                    }
                }
            }
        } else {
            buildTableModel()
        }
    }
    
    private func buildTableModel() {
        tableModel.removeAll()
        
        // Add the member count section
        tableModel.append(RosterTableModel(section: .memberCount, rows: [.memberCountRow]))
        
        // Now add the section with all of the guild members
        tableModel.append(RosterTableModel(section: .characters, rows: getMemberRows()))
    }
}

// MARK: - TableView Delegate And DataSource Functions
extension GuildRosterTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableModel[indexPath.section].rows[indexPath.row]
        let member = guildRoster?[indexPath.row]
        switch row {
        case .memberCountRow:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "GuildMemberCountCell")
            cell.textLabel?.text = localizedMemberCount()
            cell.detailTextLabel?.text = "\(guildRoster?.count ?? 0)"
            return cell
        case .characterRow:
            if let cell = tableView.dequeueReusableCell(withIdentifier: GuildMemberTableViewCell.identifier) as? GuildMemberTableViewCell, let member = member {
                cell.updateCell(withName: member.name, rank: member.rank, charClass: Classes.getClass(fromClass: member.playableClass.name), level: member.level)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - Roster Table Model
extension GuildRosterTableViewController {
    private struct RosterTableModel {
        var section: SectionType
        var rows: [RowType]
    }
    
    enum SectionType: Int {
        case memberCount
        case characters
    }
    
    enum RowType {
        case memberCountRow
        case characterRow
    }
    
    private func getMemberRows() -> [RowType] {
        var rows: [RowType] = []
        if let roster = guildRoster {
            for _ in roster {
                rows.append(.characterRow)
            }
        }
        return rows
    }
}

// MARK: - Localized Strings
extension GuildRosterTableViewController {
    private func localizedGuild() -> String {
        return NSLocalizedString("Guild Title", tableName: "Guild", bundle: .main, value: "guild title", comment: "guild title")
    }
    
    private func localizedRoster() -> String {
        return NSLocalizedString("Roster Title", tableName: "Guild", bundle: .main, value: "roster title", comment: "roster title")
    }
    
    private func localizedError() -> String {
        return NSLocalizedString("Error", tableName: "GlobalStrings", bundle: .main, value: "error title", comment: "error title")
    }
    
    private func localizedErrorRetrievingMessage() -> String {
        return NSLocalizedString("Error Retrieving Members", tableName: "Guild", bundle: .main, value: "error message", comment: "error message")
    }
    
    private func localizedMemberCount() -> String {
        return NSLocalizedString("Member Count", tableName: "Guild", bundle: .main, value: "member count", comment: "member counts")
    }
}