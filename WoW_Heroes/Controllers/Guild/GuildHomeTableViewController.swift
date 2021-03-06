//
//  GuildHomeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class GuildHomeTableViewController: UITableViewController {
    
    private var selectedCharacter: Character?
    private var selectedGuild: Guild?
    private var guildName: String?
    private var encounters: [GuildEvent] = []
    private var characterAchievements: [GuildEvent] = []
    private var guildAchievements: [GuildAchievement] = []
    private var tableModel: [GuildHomeTableModel] = []
    private var loadingMask: LoadingSpinnerViewController?
    
    init() {
        super.init(style: .grouped)
        self.title = localizedGuild()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingMask = LoadingSpinnerViewController(withViewController: self)
        tableView.register(GuildEventTableViewCell.self, forCellReuseIdentifier: GuildEventTableViewCell.identifier)
        
        // Add pull to refresh to force update event data
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshGuildEventData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedCharacter = Character.fetchSelectedCharacter()
        selectedGuild = selectedCharacter?.guild
        if let guild = selectedGuild, let realm = selectedCharacter?.realm {
            guildName = "\(guild.name) - \(realm.name)"
            self.navigationItem.title = guildName
            // Maximum refresh should be every 3 hours probably.
            if let date = Calendar.current.date(byAdding: .hour, value: -3, to: Date()), UserDefaultsHelper.getGuildLastUpdatedDate(forKey: String(format: udGuildEventsUpdated, guild.name)) < date {
                loadingMask?.showLoadingMask() {
                    self.refreshGuildEventData()
                }
            } else {
                encounters = GuildEvent.fetchEncounters(forGuild: guild)
                characterAchievements = GuildEvent.fetchCharacterAchievements(forGuild: guild)
                guildAchievements = GuildAchievement.fetchGuildAchievements(forGuild: guild)
                buildTableModel()
            }
        } else {
            self.navigationItem.title = localizedGuild()
            buildTableModel()
        }
    }
    
    private func buildTableModel() {
        tableModel.removeAll()
        if selectedGuild == nil {
            tableModel.append(GuildHomeTableModel(sectionHeader: "", section: .noGuild, rows: [.noGuild]))
        } else {
            tableModel.append(GuildHomeTableModel(sectionHeader: "", section: .rosterSection, rows: getRows(forSectionType: .rosterSection)))
            if characterAchievements.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: localizedRecentAchievements(), section: .achievementSection, rows: getRows(forSectionType: .achievementSection)))
            }
            if encounters.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: localizedRecentEncounters(), section: .encounterSection, rows: getRows(forSectionType: .encounterSection)))
            }
            if guildAchievements.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: localizedRecentGuildAchievements(), section: .guildAchievementSection, rows: getRows(forSectionType: .guildAchievementSection)))
            }
        }
        tableView.reloadData()
    }
    
    private func showErrorLoadingDataMessage() {
        let alert = UIAlertController(title: self.localizedError(), message: self.localizedErrorRetrievingMessage(), preferredStyle: .alert)
        alert.addOkayButton() { _ in
            self.endRefreshing()
        }
        alert.presentAlert(forViewController: self)
    }
    
    @objc private func refreshGuildEventData() {
        if let guild = selectedGuild {
            SCGuildEvents.getGuildEvents(forGuild: guild) { success in
                if success {
                    self.encounters = GuildEvent.fetchEncounters(forGuild: guild)
                    self.characterAchievements = GuildEvent.fetchCharacterAchievements(forGuild: guild)
                    SCGuildAchievements.getGuildAchievements(forGuild: guild) { success in
                        self.endRefreshing()
                        if success {
                            self.guildAchievements = GuildAchievement.fetchGuildAchievements(forGuild: guild)
                            self.loadingMask?.hideLoadingMask() {
                                self.buildTableModel()
                            }
                            UserDefaultsHelper.setGuildUpdatedDictionary(forKey: String(format: udGuildEventsUpdated, guild.name))
                        } else {
                            self.loadingMask?.hideLoadingMask() {
                                self.showErrorLoadingDataMessage()
                            }
                        }
                    }
                } else {
                    self.endRefreshing()
                    self.loadingMask?.hideLoadingMask() {
                        self.showErrorLoadingDataMessage()
                    }
                }
            }
        }
    }
    
    private func endRefreshing() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
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
        let row = tableModel[indexPath.section].section
        switch row {
        case .noGuild:
            return 80.0
        case .achievementSection, .encounterSection:
            return 60.0
        default:
            return 44.0
        }
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
        case .achievementSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: GuildEventTableViewCell.identifier) as? GuildEventTableViewCell, let character = characterAchievements[indexPath.row].character {
                let achievement = characterAchievements[indexPath.row].eventName
                cell.updateCellAsAchievement(forCharacter: character, achievementName: achievement)
                return cell
            }
        case .encounterSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: GuildEventTableViewCell.identifier) as? GuildEventTableViewCell {
                if let selectedGuild = selectedGuild, let difficulty = encounters[indexPath.row].difficulty {
                    let encounter = encounters[indexPath.row].eventName
                    cell.updateCellAsEncounter(forGuild: selectedGuild.name, encounterName: encounter, difficulty: difficulty)
                }
                return cell
            }
        case .guildAchievementSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: GuildEventTableViewCell.identifier) as? GuildEventTableViewCell, let guild = selectedGuild {
                let achievement = guildAchievements[indexPath.row].name
                cell.updateCellAsAchievement(forCharacter: guild.name, achievementName: achievement)
                return cell
            }
        }
        return UITableViewCell()
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
        case guildAchievementSection
        case noGuild
    }
    
    private enum RowType: Int {
        case rosterRow
        case achievementRow
        case encounterRow
        case guildAchievementRow
        case noGuild
    }
    
    private func getRows(forSectionType section: SectionType) -> [RowType] {
        switch section {
        case .noGuild:
            return []
        case .rosterSection:
            return getRosterRows()
        case .encounterSection:
            return getEncounterRows()
        case .achievementSection:
            return getAchievementRows()
        case .guildAchievementSection:
            return getGuildAchievementRows()
        }
    }
    
    private func getRosterRows() -> [RowType] {
        return [.rosterRow]
    }
    
    private func getEncounterRows() -> [RowType] {
        var rows: [RowType] = []
        for _ in encounters {
            rows.append(.encounterRow)
        }
        return rows
    }
    
    private func getAchievementRows() -> [RowType] {
        var rows: [RowType] = []
        for _ in characterAchievements {
            rows.append(.achievementRow)
        }
        return rows
    }
    
    private func getGuildAchievementRows() -> [RowType] {
        var rows: [RowType] = []
        for _ in guildAchievements {
            rows.append(.guildAchievementRow)
        }
        return rows
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
    
    private func localizedError() -> String {
        return NSLocalizedString("Error", tableName: "GlobalStrings", bundle: .main, value: "error title", comment: "error title")
    }
    
    private func localizedErrorRetrievingMessage() -> String {
        return NSLocalizedString("Error Retrieving Events", tableName: "Guild", bundle: .main, value: "error message", comment: "error message")
    }
    
    private func localizedRecentAchievements() -> String {
        return NSLocalizedString("Recent Achievements", tableName: "Guild", bundle: .main, value: "recent achievements", comment: "recent achievements")
    }
    
    private func localizedRecentEncounters() -> String {
        return NSLocalizedString("Recent Encounters", tableName: "Guild", bundle: .main, value: "recent encounters", comment: "recent encounters")
    }
    
    private func localizedRecentGuildAchievements() -> String {
        return NSLocalizedString("Recent Guild Achievements", tableName: "Guild", bundle: .main, value: "recent guild achievements", comment: "recent guild achievements")
    }
}
