//
//  GuildAchievement.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(GuildAchievement)
class GuildAchievement: WHNSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var timestamp: Int64
    @NSManaged var guild: Guild
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Character Achievement Fetch Functions
extension GuildAchievement {
    
    /**
     Fetch a guild achievement
     
     - Parameter achievementName: Name for the achievement.
     - Returns the achievement if it exists. Otherwise returns nil.
     */
    class func fetchGuildAchievement(achievementName: String) -> GuildAchievement? {
        return fetchGuildAchievement(achievementName: achievementName, context: self.WHManagedObjectContext())
    }
    
    class func fetchGuildAchievement(achievementName: String, context: NSManagedObjectContext) -> GuildAchievement? {
        let predicate = NSPredicate(format: "name == %@", achievementName)
        do {
            let request = NSFetchRequest<GuildAchievement>(entityName: self.identifier())
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
    
    /**
     Fetch all guild achievement
     
     - Parameter guild: Name of the guild to get achievements for.
     - Returns an array of achievements.
     */
    class func fetchGuildAchievements(forGuild guild: Guild) -> [GuildAchievement] {
        return fetchGuildAchievements(forGuild: guild, context: self.WHManagedObjectContext())
    }
    
    class func fetchGuildAchievements(forGuild guild: Guild, context: NSManagedObjectContext) -> [GuildAchievement] {
        let predicate = NSPredicate(format: "guild.name == %@", guild.name)
        do {
            let request = NSFetchRequest<GuildAchievement>(entityName: self.identifier())
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

extension GuildAchievement {
    func updateGuildAchievement(fromGuildAchievement achieve: GuildAchievement) {
        self.name = achieve.name
        self.timestamp = achieve.timestamp
    }
}
