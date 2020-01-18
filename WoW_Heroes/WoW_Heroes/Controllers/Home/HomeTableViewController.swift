//
//  HomeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 1/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

	var tableModel = [HomeTableModel]()
	
	init() {
		super.init(style: .grouped)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = localizedScreenTitle()
		buildTableModel()
    }
	
	func buildTableModel() {
		tableModel.removeAll()
		tableModel.append(HomeTableModel(sectionType: .CharacterSelection, rows: ["Smarmee"]))
		tableModel.append(HomeTableModel(sectionType: .AllCharacters, rows: generateAllCharacters()))
	}
}

    // MARK: - Table view data source
extension HomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
		return tableModel.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel[section].rows.count
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		var sectionHeader = ""
		switch tableModel[section].sectionType{
		case .CharacterSelection:
			sectionHeader = localizedCharacterSelectionHeader()
		case .AllCharacters:
			sectionHeader = localizedAllCharacterHeader()
		}
		return sectionHeader
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}

extension HomeTableViewController {
	func localizedScreenTitle() -> String {
		return NSLocalizedString("Screen Title", tableName: "Home", bundle: .main, value: "screen title", comment: "screen title")
	}

	func localizedCharacterSelectionHeader() -> String {
		return NSLocalizedString("Character Select Header", tableName: "Home", bundle: .main, value: "character section header", comment: "character section header")
	}
	
	func localizedAllCharacterHeader() -> String {
		return NSLocalizedString("All Characters Header", tableName: "Home", bundle: .main, value: "all character section header", comment: "all character section header")
	}
}

// MARK: - Table Model Functions
extension HomeTableViewController {
	struct HomeTableModel {
		var sectionType: SectionType
		var rows: [String]
	}
	
	enum SectionType: Int {
		case CharacterSelection = 0
		case AllCharacters
	}
	
	func generateAllCharacters() -> [String] {
		return ["Smarmie-Mal'Ganis 120", "Smarmee-Mal'Ganis 120", "Smarmies-Mal'Ganis 120", "Smarmied-Mal'Ganis 120", "Smarmied-Mal'Ganis 120"]
	}
}
