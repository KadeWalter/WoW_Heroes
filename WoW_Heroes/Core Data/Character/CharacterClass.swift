//
//  CharacterClass.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/7/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(CharacterClass)
class CharacterClass: WHNSManagedObject {
    
    @NSManaged var id: Int16
    @NSManaged var name: String
    @NSManaged var characters: Set<Character>
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// Mark: Helper Functions
extension CharacterClass {
    func getColor(forClass charClass: Classes) -> String {
        // TODO: - Finish this.
//        switch charClass {
//        case .:
//            <#code#>
//        default:
//            <#code#>
//        }
        return ""
    }
}

// MARK: - Fetch Functions
extension CharacterClass {
    class func fetchCharacterClass(withId id: Int16, name: String) -> CharacterClass? {
        return fetchCharacterClass(withId: id, name: name, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchCharacterClass(withId id: Int16, name: String, context: NSManagedObjectContext) -> CharacterClass? {
        let predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
        do {
            let request = NSFetchRequest<CharacterClass>(entityName: CharacterClass.identifier())
            request.predicate = predicate
            
            let charClasses = try context.fetch(request)
            if charClasses.count == 1, let charClass = charClasses.first {
                return charClass
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension CharacterClass {
    func updateCharacterClass(fromCharacterClass charClass: CharacterClass) {
        self.id = charClass.id
        self.name = charClass.name
    }
    
    enum Classes: String {
        case DeathKnight = "Death Knight"
        case DemonHunter = "Demon Hunter"
        case Druid
        case Hunter
        case Mage
        case Monk
        case Paladin
        case Priest
        case Rogue
        case Shaman
        case Warlock
        case Warrior
    }
}
