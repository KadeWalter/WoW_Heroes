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
    var encounters: [GuildEvent] = []
    var characterAchievements: [GuildEvent] = []
    var guildAchievements: [GuildAchievement] = []
    private var tableModel: [GuildHomeTableModel] = []
    var loadingMask: LoadingSpinnerViewController?
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedCharacter = Character.fetchSelectedCharacter()
        selectedGuild = selectedCharacter?.guild
        if let guild = selectedGuild, let realm = selectedCharacter?.realm {
            guildName = "\(guild.name) - \(realm.name)"
            self.navigationItem.title = guildName
            // Maximum refresh should be every 3 hours probably.
            if let date = Calendar.current.date(byAdding: .hour, value: -3, to: Date()), UserDefaultsHelper.getGuildLastUpdatedDate(forKey: String(format: udGuildEventsUpdated, guild.name)) < date {
                loadingMask?.showLoadingMask() {
                    SCGuildEvents.getGuildEvents(forGuild: guild) { success in
                        if success {
                            self.encounters = GuildEvent.fetchEncounters(forGuild: guild)
                            self.characterAchievements = GuildEvent.fetchCharacterAchievements(forGuild: guild)
                            SCGuildAchievements.getGuildAchievements(forGuild: guild) { success in
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
                            self.loadingMask?.hideLoadingMask() {
                                self.showErrorLoadingDataMessage()
                            }
                        }
                    }
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
            // TODO: - Localize Strings
            tableModel.append(GuildHomeTableModel(sectionHeader: "", section: .rosterSection, rows: getRows(forSectionType: .rosterSection)))
            if characterAchievements.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: "Recent Achievements", section: .achievementSection, rows: getRows(forSectionType: .achievementSection)))
            }
            if encounters.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: "Recent Encounters", section: .encounterSection, rows: getRows(forSectionType: .encounterSection)))
            }
            if guildAchievements.count > 0 {
                tableModel.append(GuildHomeTableModel(sectionHeader: "Recent Guild Achievements", section: .guildAchievementSection, rows: getRows(forSectionType: .guildAchievementSection)))
            }
        }
        tableView.reloadData()
    }
    
    private func showErrorLoadingDataMessage() {
        
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
}
