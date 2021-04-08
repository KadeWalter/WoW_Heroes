//
//  COMRealm.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/3/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

final class SCRealmIndex {
    
    private static var region: String = ""
    
    class func getRealms(region: String, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        self.region = region
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: region))/data/wow/realm/index"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: region, withUrlString: urlString, forNamespace: .dynamic) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetRealms") { data, response, error in
                if error == nil {
                    guard let data = data else { completion(false); return }
                    completion(processRealmData(data: data))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processRealmData(data: Data) -> Bool {
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        
        // Add the realms to core data.
        var success: Bool = false
        managedObjectContext.performAndWait {
            do {
                // Try to decode the realm data from the service call. And store the realms in core data.
                let decodedRealmData = try JSONDecoder().decode(Realms.self, from: data)
                for realm in decodedRealmData.realms {
                    self.importRealm(withData: realm, region: region, context: managedObjectContext)
                }
                
                // If there was a change from the last set of realms, then save them.
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
                
                // Set the next realm fetch date to now + 7 days.
                let calendar = Calendar.current
                let nextRefreshDate = calendar.date(byAdding: .day, value: 3, to: Date())
                UserDefaultsHelper.set(value: nextRefreshDate, forKey: "\(udRealmRefreshDate)\(region)")
                success = true
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return success
    }
    
    private class func importRealm(withData realmData: RealmData, region: String, context: NSManagedObjectContext) {
        guard let realm = Realm.createWithoutInsert(context: context) else { return }
        realm.name = realmData.name
        realm.slug = realmData.slug
        realm.id = realmData.id
        realm.region = region
        
        if let existingRealm = Realm.fetchRealm(withId: Int(realmData.id), region: region, context: context) {
            // If the realm already exists, just update it.
            // For realms, this should never hit because we delete all realms for a region before making the call for new realms.
            // Keeping this here just incase.
            existingRealm.updateRealm(fromRealm: realm)
        } else {
            // Otherwise, insert a new one into Core Data.
            realm.insert(intoContext: context)
        }
    }
}

// Structs for decoding realms.
extension SCRealmIndex {
    private struct Realms: Codable {
        var realms: [RealmData]
    }
    
    private struct RealmData: Codable {
        var name: String
        var id: Int32
        var slug: String
    }
}
