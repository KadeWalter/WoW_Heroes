//
//  GuildHomeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class GuildHomeTableViewController: UITableViewController {

    var selectedCharacter: Character?
    var selectedGuild: Guild?
    var guildName: String?
    private var tableModel: [GuildHomeTableModel] = []
    
    init() {
        super.init(style: .grouped)
        self.title = localizedGuild()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        selectedCharacter = Character.fetchSelectedCharacter()
        selectedGuild = selectedCharacter?.guild
        if let guild = selectedGuild, let realm = selectedCharacter?.realm {
            guildName = "\(guild.name) - \(realm.name)"
            self.navigationItem.title = guildName
        } else {
            self.navigationItem.title = localizedGuild()
        }
        buildTableModel()
    }
    
    private func buildTableModel() {
        tableModel.removeAll()
        if selectedGuild == nil {
            tableModel.append(GuildHomeTableModel(sectionHeader: "", section: .noGuild, rows: [.noGuild]))
        } else {
            tableModel.append(GuildHomeTableModel(sectionHeader: "", section: .rosterSection, rows: getRows(forSection: .rosterSection)))
        }
        tableView.reloadData()
    }
    
}

// MARK: - TableView Delegate and DataSource Functions
extension GuildHomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModel.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableModel[section].sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableModel[indexPath.section].section == .noGuild ? 80.0 : 44.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = tableModel[indexPath.section].section
        switch section {
        case .noGuild:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "GuildHomeNoGuildCell")
            cell.textLabel?.text = localizedNoGuild()
            cell.textLabel?.numberOfLines = 0
            return cell
        case .rosterSection:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "GuildHomeRosterCell")
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = localizedRoster()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return tableModel[indexPath.section].section == .rosterSection
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = tableModel[indexPath.section].section
        switch section {
        case .rosterSection:
            if let guild = selectedGuild {
                let rosterVC = GuildRosterTableViewController(withTitle: guildName ?? localizedRoster(), guild: guild)
                self.navigationController?.pushViewController(rosterVC, animated: true)
            }
        default:
            break
        }
    }
}

// MARK: - Guild Home Table Model
extension GuildHomeTableViewController {
    private struct GuildHomeTableModel {
        var sectionHeader: String
        var section: SectionType
        var rows: [RowType]
    }
    
    private enum SectionType: Int {
        case rosterSection
        case achievementSection
        case encounterSection
        case noGuild
    }
    
    private enum RowType: Int {
        case rosterRow
        case achievementRow
        case encounterRow
        case noGuild
    }
    
    private func getRows(forSection section: SectionType) -> [RowType] {
        switch section {
        case .rosterSection:
            return getRosterRows()
        default:
            return []
        }
    }
    
    private func getRosterRows() -> [RowType] {
        return [.rosterRow]
    }
}

// MARK: - Localized Strings
extension GuildHomeTableViewController {
    private func localizedGuild() -> String {
        return NSLocalizedString("Guild Title", tableName: "Guild", bundle: .main, value: "guild title", comment: "guild title")
    }
    
    private func localizedRoster() -> String {
        return NSLocalizedString("Roster Title", tableName: "Guild", bundle: .main, value: "roster title", comment: "roster title")
    }
    
    private func localizedNoGuild() -> String {
        return NSLocalizedString("No Guild Message", tableName: "Guild", bundle: .main, value: "no guild message", comment: "no guild message")
    }
}
