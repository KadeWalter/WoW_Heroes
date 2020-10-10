//
//  CharacterClass.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/7/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit
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
    class func getColor(forClass charClass: Classes) -> UIColor {
        switch charClass {
        case .DeathKnight:
            return UIColor(hex: "#C41F3B")
        case .DemonHunter:
            return UIColor(hex: "#A330C9")
        case .Druid:
            return UIColor(hex: "#FF7D0A")
        case .Hunter:
            return UIColor(hex: "#A9D271")
        case .Mage:
            return UIColor(hex: "#40C7EB")
        case .Monk:
            return UIColor(hex: "#00FF96")
        case .Paladin:
            return UIColor(hex: "#F58CBA")
        case .Priest:
            // Because Priest is dumb and white, we are just going to settle with grey.
            return UIColor(hex: "#777777")
        case .Rogue:
            return UIColor(hex: "#FFF569")
        case .Shaman:
            return UIColor(hex: "#0070DE")
        case .Warlock:
            return UIColor(hex: "#8787ED")
        case .Warrior:
            return UIColor(hex: "#C79C6E")
        default:
            return .black
        }
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
    case ClassNotFound
    
    static func getClass(fromClass charClass: String) -> Classes {
        if charClass == Classes.DeathKnight.rawValue {
            return .DeathKnight
        } else if charClass == Classes.DemonHunter.rawValue {
            return .DemonHunter
        } else if charClass == Classes.Druid.rawValue {
            return .Druid
        } else if charClass == Classes.Hunter.rawValue {
            return .Hunter
        } else if charClass == Classes.Mage.rawValue {
            return .Mage
        } else if charClass == Classes.Monk.rawValue {
            return .Monk
        } else if charClass == Classes.Paladin.rawValue {
            return .Paladin
        } else if charClass == Classes.Priest.rawValue {
            return .Priest
        } else if charClass == Classes.Rogue.rawValue {
            return .Rogue
        } else if charClass == Classes.Shaman.rawValue {
            return .Shaman
        } else if charClass == Classes.Warlock.rawValue {
            return .Warlock
        } else if charClass == Classes.Warrior.rawValue {
            return .Warrior
        }
        return .ClassNotFound
    }
}
