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
class Realm: WHNSManagedObject, Codable {
    @NSManaged var name: String
    @NSManaged var slug: String
    @NSManaged var id: Int32
    @NSManaged var region: String
    
    required convenience init(from decoder: Decoder) throws {
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Realm", in: managedObjectContext) else {
            throw GenericNSManageObjectError.managedObjectContextError
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.slug = try container.decode(String.self, forKey: .slug)
        self.id = try container.decode(Int32.self, forKey: .id)
        self.region = ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(slug, forKey: .slug)
        try container.encode(id, forKey: .id)
        try container.encode(region, forKey: .region)
    }
    
    override class func identifier() -> String {
        return String(describing: self)
    }
    
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
    
    class func fetchAllRealms(forRegion region: String) -> [Realm] {
        return fetchAllRealms(forRegion: region, context: WHNSManagedObject.WHManagedObjectContext())
    }
    
    class func fetchAllRealms(forRegion region: String, context: NSManagedObjectContext) -> [Realm] {
        let predicate = NSPredicate(format: "region == %@", region)
        do {
            let request = NSFetchRequest<Realm>(entityName: Realm.identifier())
            request.predicate = predicate
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
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case slug = "slug"
        case id = "id"
        case region = "region"
    }
}
