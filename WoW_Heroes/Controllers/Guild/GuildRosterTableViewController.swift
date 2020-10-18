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
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshGuildRoster))
        self.navigationItem.rightBarButtonItem = refreshButton
        loadingMask = LoadingSpinnerViewController(withViewController: self)
        tableView.register(GuildMemberTableViewCell.self, forCellReuseIdentifier: GuildMemberTableViewCell.identifier)
        getRosterInformation()
    }
    
    private func getRosterInformation() {
        // if it returns 0 results, we need to fetch for a new roster. otherwise build the table model.
        if let date = Calendar.current.date(byAdding: .hour, value: -3, to: Date()), UserDefaultsHelper.getGuildLastUpdatedDate(forKey: String(format: udGuildRosterUpdated, guild.name)) < date {
            loadingMask?.showLoadingMask() {
                GuildRosterMember.deleteRoster(forGuild: self.guild)
                SCGuildRoster.getRoster(region: self.guild.realm.region, guildSlug: self.guild.slug, realmSlug: self.guild.realm.slug) { success in
                    if success {
                        self.guildRoster = GuildRosterMember.fetchGuildMembers(withGuildId: self.guild.id, guildName: self.guild.name)
                        self.loadingMask?.hideLoadingMask() {
                            self.buildTableModel()
                        }
                        UserDefaultsHelper.setGuildUpdatedDictionary(forKey: String(format: udGuildRosterUpdated, self.guild.name))
                    } else {
                        self.loadingMask?.hideLoadingMask() {
                            let alert = UIAlertController(title: self.localizedError(), message: self.localizedErrorRetrievingMessage(), preferredStyle: .alert)
                            alert.addOkayButton()
                            alert.presentAlert(forViewController: self)
                        }
                    }
                }
            }
        } else {
            guildRoster = GuildRosterMember.fetchGuildMembers(withGuildId: guild.id, guildName: guild.name)
            buildTableModel()
        }
    }
    
    private func buildTableModel() {
        tableModel.removeAll()
        // Add the member count section
        tableModel.append(RosterTableModel(section: .memberCount, rows: [.memberCountRow]))
        // Now add the section with all of the guild members
        tableModel.append(RosterTableModel(section: .characters, rows: getMemberRows()))
        tableView.reloadData()
    }
    
    @objc func refreshGuildRoster() {
        // delete all entries for the guild.
        GuildRosterMember.deleteRoster(forGuild: guild)
        // get refreshed data.
        self.loadingMask?.showLoadingMask() {
            SCGuildRoster.getRoster(region: self.guild.realm.region, guildSlug: self.guild.slug, realmSlug: self.guild.realm.slug) { success in
                if success {
                    self.guildRoster = GuildRosterMember.fetchGuildMembers(withGuildId: self.guild.id, guildName: self.guild.name)
                    self.loadingMask?.hideLoadingMask() {
                        self.buildTableModel()
                    }
                    UserDefaultsHelper.setGuildUpdatedDictionary(forKey: String(format: udGuildRosterUpdated, self.guild.name))
                } else {
                    self.loadingMask?.hideLoadingMask() {
                        let alert = UIAlertController(title: self.localizedError(), message: self.localizedErrorRetrievingMessage(), preferredStyle: .alert)
                        alert.addOkayButton()
                        alert.presentAlert(forViewController: self)
                    }
                }
            }
        }
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
