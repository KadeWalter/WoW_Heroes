//
//  GuildRosterMember.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(GuildRosterMember)
class GuildRosterMember: WHNSManagedObject {
    
    @NSManaged var level: Int16
    @NSManaged var rank: Int16
    @NSManaged var name: String
    @NSManaged var guild: Guild
    @NSManaged var playableClass: CharacterClass
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Fetch Functions
extension GuildRosterMember {
    class func fetchGuildMember(withName name: String, guildName: String) -> GuildRosterMember? {
        return fetchGuildMember(withName: name, guildName: guildName, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchGuildMember(withName name: String, guildName: String, context: NSManagedObjectContext) -> GuildRosterMember? {
        let predicate = NSPredicate(format: "name == %@ AND guild.name == %@", name, guildName)
        do {
            let request = NSFetchRequest<GuildRosterMember>(entityName: GuildRosterMember.identifier())
            request.predicate = predicate
            
            let roster = try context.fetch(request)
            if roster.count == 1, let character = roster.first {
                return character
            }
            return nil
        } catch {
            return nil
        }
    }
    
    class func fetchGuildMembers(withGuildId id: Int64, guildName: String) -> [GuildRosterMember]? {
        return fetchGuildMembers(withGuildId: id, guildName: guildName, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchGuildMembers(withGuildId id: Int64, guildName: String, context: NSManagedObjectContext) -> [GuildRosterMember]? {
        let predicate = NSPredicate(format: "guild.id == %d AND guild.name == %@", id, guildName)
        do {
            let request = NSFetchRequest<GuildRosterMember>(entityName: GuildRosterMember.identifier())
            request.predicate = predicate
            
            let sortByRank = NSSortDescriptor(key: "rank", ascending: true)
            let sortByLevel = NSSortDescriptor(key: "level", ascending: false)
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortByRank, sortByLevel, sortByName]
            
            let roster = try context.fetch(request)
            return roster
        } catch {
            return nil
        }
    }
}

extension GuildRosterMember {
    func updateGuildRosterMember(fromMember member: GuildRosterMember) {
        self.level = member.level
        self.name = member.name
        self.rank = member.rank
    }
}
