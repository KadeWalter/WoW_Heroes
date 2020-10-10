//
//  Guild.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/7/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(Guild)
class Guild: WHNSManagedObject {
    
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var faction: String
    @NSManaged var characters: Set<Character>
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Fetch Functions
extension Guild {
    class func fetchGuild(withId id: Int64, name: String) -> Guild? {
        return fetchGuild(withId: id, name: name, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchGuild(withId id: Int64, name: String, context: NSManagedObjectContext) -> Guild? {
        let predicate = NSPredicate(format: "id == %d AND name == %@", id, name)
        do {
            let request = NSFetchRequest<Guild>(entityName: Guild.identifier())
            request.predicate = predicate
            
            let guilds = try context.fetch(request)
            if guilds.count == 1, let guild = guilds.first {
                return guild
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

extension Guild {
    func updateGuild(fromGuild guild: Guild) {
        self.id = guild.id
        self.name = guild.name
        self.faction = guild.faction
        self.characters = guild.characters
    }
}
