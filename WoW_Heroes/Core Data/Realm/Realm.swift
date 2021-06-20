//
//  Realm.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 8/5/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

@objc(Realm)
class Realm: WHNSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var slug: String
    @NSManaged var id: Int32
    @NSManaged var region: String
    @NSManaged var characters: Set<Character>
    @NSManaged var guilds: Set<Guild>
    
    override class func identifier() -> String {
        return String(describing: self)
    }
}

// MARK: - Fetch and Delete Functions
extension Realm {
    
    /**
     Fetch a specific realm.
     
     - Parameter id: Id for the realm.
     - Parameter region: Region for the realm.
     - Returns the realm if it exists. Otherwise returns nil.
     */
    class func fetchRealm(withId id: Int, region: String) -> Realm? {
        return fetchRealm(withId: id, region: region, context: self.WHManagedObjectContext())
    }
    
    class func fetchRealm(withId id: Int, region: String, context: NSManagedObjectContext) -> Realm? {
        let predicate = NSPredicate(format: "id == %d AND region == %@", id, region)
        do {
            let request = NSFetchRequest<Realm>(entityName: self.identifier())
            request.predicate = predicate
            
            let realms = try context.fetch(request)
            if realms.count == 1, let realm = realms.first {
                return realm
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    /**
     Fetch all realms for a given region.
     
     - Parameter region: The region to get realms for.
     - Returns an array of realms for the region.
     */
    class func fetchAllRealms(forRegion region: String) -> [Realm] {
        return fetchAllRealms(forRegion: region, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchAllRealms(forRegion region: String, context: NSManagedObjectContext) -> [Realm] {
        let predicate = NSPredicate(format: "region == %@", region)
        do {
            let request = NSFetchRequest<Realm>(entityName: self.identifier())
            request.predicate = predicate
            
            let sortByName = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortByName]
            
            let realms = try context.fetch(request)
            return realms
        } catch {
            return []
        }
    }
}

extension Realm {
    func updateRealm(fromRealm realm: Realm) {
        self.name = realm.name
        self.slug = realm.slug
        self.id = realm.id
        self.region = realm.region
    }
    
    func addCharacter(character: Character) {
        self.characters.insert(character)
    }
}
