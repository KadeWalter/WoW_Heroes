//
//  GuildEvent.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/16/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(GuildEvent)
class GuildEvent: WHNSManagedObject {
    
    @NSManaged var character: String?
    @NSManaged var difficulty: String?
    @NSManaged var eventName: String
    @NSManaged var timestamp: Int64
    @NSManaged var type: String
    @NSManaged var guild: Guild
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Character Achievement Fetch Functions
extension GuildEvent {
    class func fetchCharacterAchievement(achievementName: String, characterName: String, type: String) -> GuildEvent? {
        return fetchCharacterAchievement(achievementName: achievementName, characterName: characterName, type: type, context: self.WHManagedObjectContext())
    }
    
    class func fetchCharacterAchievement(achievementName: String, characterName: String, type: String, context: NSManagedObjectContext) -> GuildEvent? {
        let predicate = NSPredicate(format: "eventName == %@ AND character == %@ AND type == %@", achievementName, characterName, type)
        do {
            let request = NSFetchRequest<GuildEvent>(entityName: self.identifier())
            request.predicate = predicate
            
            let achievements = try context.fetch(request)
            if achievements.count == 1, let achievement = achievements.first {
                return achievement
            }
            return nil
        } catch {
            return nil
        }
    }
    
    class func fetchCharacterAchievements(forGuild guild: Guild) -> [GuildEvent] {
        return fetchCharacterAchievements(forGuild: guild, context: self.WHManagedObjectContext())
    }
    
    class func fetchCharacterAchievements(forGuild guild: Guild, context: NSManagedObjectContext) -> [GuildEvent] {
        let predicate = NSPredicate(format: "guild.name == %@ AND type == %@", guild.name, GuildEventTypes.CharacterAchievement.rawValue)
        do {
            let request = NSFetchRequest<GuildEvent>(entityName: self.identifier())
            request.predicate = predicate
            request.fetchLimit = 10
            
            let sortByTime = NSSortDescriptor(key: "timestamp", ascending: false)
            request.sortDescriptors = [sortByTime]
            
            let achievements = try context.fetch(request)
            return achievements
        } catch {
            return []
        }
    }
}

// MARK: - Encounter Fetch Functions
extension GuildEvent {
    class func fetchEncounter(encounterName: String, difficulty: String, type: String) -> GuildEvent? {
        return fetchEncounter(encounterName: encounterName, difficulty: difficulty, type: type, context: self.WHManagedObjectContext())
    }
    
    class func fetchEncounter(encounterName: String, difficulty: String, type: String, context: NSManagedObjectContext) -> GuildEvent? {
        let predicate = NSPredicate(format: "eventName == %@ AND difficulty == %@ AND type == %@", encounterName, difficulty, type)
        do {
            let request = NSFetchRequest<GuildEvent>(entityName: self.identifier())
            request.predicate = predicate
            
            let encounters = try context.fetch(request)
            if encounters.count == 1, let encounter = encounters.first {
                return encounter
            }
            return nil
        } catch {
            return nil
        }
    }
    
    class func fetchEncounters(forGuild guild: Guild) -> [GuildEvent] {
        return fetchEncounters(forGuild: guild, context: self.WHManagedObjectContext())
    }
    
    class func fetchEncounters(forGuild guild: Guild, context: NSManagedObjectContext) -> [GuildEvent] {
        let predicate = NSPredicate(format: "guild.name == %@ AND type == %@", guild.name, GuildEventTypes.Encounter.rawValue)
        do {
            let request = NSFetchRequest<GuildEvent>(entityName: self.identifier())
            request.predicate = predicate
            request.fetchLimit = 10
            
            let sortByTime = NSSortDescriptor(key: "timestamp", ascending: false)
            request.sortDescriptors = [sortByTime]
            
            let encounters = try context.fetch(request)
            return encounters
        } catch {
            return []
        }
    }
}

extension GuildEvent {
    func updateCharacterAchievement(fromEventInfo event: GuildEvent) {
        self.character = event.character
        self.eventName = event.eventName
        self.timestamp = event.timestamp
        self.type = event.type
    }
    
    func updateGuildEncounter(fromEventInfo event: GuildEvent) {
        self.difficulty = event.difficulty
        self.eventName = event.eventName
        self.timestamp = event.timestamp
        self.type = event.type
    }

    enum GuildEventTypes: String {
        case CharacterAchievement = "CHARACTER_ACHIEVEMENT"
        case Encounter = "ENCOUNTER"
    }
}
