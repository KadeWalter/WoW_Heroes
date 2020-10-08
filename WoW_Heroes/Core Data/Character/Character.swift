//
//  Character.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/7/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(Character)
class Character: WHNSManagedObject {
    
    @NSManaged var activeSpec: String
    @NSManaged var activeTitle: String
    @NSManaged var averageIlvl: Int16
    @NSManaged var equippedIlvl: Int16
    @NSManaged var faction: String
    @NSManaged var gender: String
    @NSManaged var id: Int64
    @NSManaged var level: Int16
    @NSManaged var name: String
    @NSManaged var race: String
    @NSManaged var characterClass: CharacterClass
    @NSManaged var guild: Guild
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Fetch Functions
extension Character {
    class func fetchCharacter(withId id: Int64, name: String) -> Character? {
        return fetchCharacter(withId: id, name: name, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchCharacter(withId id: Int64, name: String, context: NSManagedObjectContext) -> Character? {
        let predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
        do {
            let request = NSFetchRequest<Character>(entityName: Character.identifier())
            request.predicate = predicate
            
            let chars = try context.fetch(request)
            if chars.count == 1, let char = chars.first {
                return char
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension Character {
    func updateCharacter(fromCharacter character: Character) {
        self.activeSpec = character.activeSpec
        self.activeTitle = character.activeTitle
        self.averageIlvl = character.averageIlvl
        self.equippedIlvl = character.equippedIlvl
        self.faction = character.faction
        self.gender = character.gender
        self.id = character.id
        self.level = character.level
        self.name = character.name
        self.race = character.race
    }
}
