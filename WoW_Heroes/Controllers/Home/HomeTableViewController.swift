//
//  HomeTableViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 1/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var characters: [NSManagedObject] = []
    
    init() {
        super.init(style: .grouped)
        let addCharacterButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCharacter))
        addCharacterButton.tintColor = .red
        self.navigationItem.rightBarButtonItem = addCharacterButton
        navigationItem.title = "Home"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Table view data source
extension HomeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let character = characters[indexPath.row]
        cell.textLabel?.text = character.value(forKey: "name") as? String ?? ""
        return cell
    }
}

// MARK: - Class Helper Functions
extension HomeTableViewController {
    @objc func addNewCharacter() {
        let vc = RegionSelectTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Added Character Delegate
extension HomeTableViewController: CharacterAddedDelegate {
    func characterAdded(characterName name: String, realm: Realm) {
        return
    }
}

// TODO: Localize Strings 
