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
    class func fetchRealm(withId id: Int, region: String) -> Realm? {
        return fetchRealm(withId: id, region: region, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchRealm(withId id: Int, region: String, context: NSManagedObjectContext) -> Realm? {
        let predicate = NSPredicate(format: "id == %d AND region == %@", id, region)
        do {
            let request = NSFetchRequest<Realm>(entityName: Realm.identifier())
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
    
    // Get All Realms For A Region
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
