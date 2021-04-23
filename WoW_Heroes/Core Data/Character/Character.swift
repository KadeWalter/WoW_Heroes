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
    
    @NSManaged var achievementPoints: Int32
    @NSManaged var activeSpec: String
    @NSManaged var activeTitle: String?
    @NSManaged var averageIlvl: Int16
    @NSManaged var covenantName: String
    @NSManaged var equippedIlvl: Int16
    @NSManaged var faction: String
    @NSManaged var gender: String
    @NSManaged var id: Int64
    @NSManaged var level: Int16
    @NSManaged var name: String
    @NSManaged var race: String
    @NSManaged var isSelectedCharacter: Bool
    @NSManaged var characterClass: CharacterClass
    @NSManaged var guild: Guild?
    @NSManaged var realm: Realm
    @NSManaged var renownLevel: Int16
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Fetch Functions
extension Character {
    class func fetchCharacter(withId id: Int64, name: String) -> Character? {
        return fetchCharacter(withId: id, name: name, context: self.WHManagedObjectContext())
    }
    
    class func fetchCharacter(withId id: Int64, name: String, context: NSManagedObjectContext) -> Character? {
        let predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
        do {
            let request = NSFetchRequest<Character>(entityName: self.identifier())
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
    
    class func fetchSelectedCharacter() -> Character? {
        return fetchSelectedCharacter(context: self.WHManagedObjectContext())
    }
    
    class func fetchSelectedCharacter(context: NSManagedObjectContext) -> Character? {
        do {
            let request = NSFetchRequest<Character>(entityName: self.identifier())
            let predicate = NSPredicate(format: "isSelectedCharacter == true")
            request.predicate = predicate
            
            let characters = try context.fetch(request)
            if characters.count == 1, let character = characters.first {
                return character
            }
            return nil
        } catch {
            return nil
        }
    }
    
    class func fetchAllCharacters() -> [Character] {
        let characters = fetchAllCharacters(context: WHNSManagedObject.WHManagedObjectContext())
        return characters
    }
    
    class func fetchAllCharacters(context: NSManagedObjectContext) -> [Character] {
        do {
            let request = NSFetchRequest<Character>(entityName: self.identifier())
            
            let sortByLevel = NSSortDescriptor(key: "level", ascending: false)
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortByLevel, sortByName]
            
            let characters = try context.fetch(request)
            return characters
        } catch {
            return []
        }
    }
    
    class func deleteCharacter(withCharacter character: Character) {
        deleteCharacter(withCharacter: character, context: self.WHManagedObjectContext())
    }
    
    class func deleteCharacter(withCharacter character: Character, context: NSManagedObjectContext) {
        context.performAndWait {
            context.delete(character)
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    class func setIsSelected(forCharacters characters: [Character], isSelected: Bool) {
        setIsSelected(forCharacters: characters, isSelected: isSelected, context: self.WHManagedObjectContext())
    }
    
    class func setIsSelected(forCharacters characters: [Character], isSelected: Bool, context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                for char in characters {
                    char.isSelectedCharacter = isSelected
                }
                if context.hasChanges {
                    try context.save()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

extension Character {
    func updateCharacter(fromCharacter character: Character) {
        self.achievementPoints = character.achievementPoints
        self.activeSpec = character.activeSpec
        self.activeTitle = character.activeTitle
        self.averageIlvl = character.averageIlvl
        self.covenantName = character.covenantName
        self.equippedIlvl = character.equippedIlvl
        self.faction = character.faction
        self.gender = character.gender
        self.id = character.id
        self.level = character.level
        self.name = character.name
        self.race = character.race
        self.isSelectedCharacter = character.isSelectedCharacter
        self.renownLevel = character.renownLevel
    }
}
