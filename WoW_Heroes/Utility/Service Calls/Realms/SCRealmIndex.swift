//
//  COMRealm.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/3/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import CoreData
import UIKit

final class SCRealmIndex {
    
    private static var region: String = ""
    
    class func getRealms(region: String, completion: @escaping (Bool) -> Void) {
        // Create Params
        self.region = region
        var params: [String : String] = [:]
        params["namespace"] = "dynamic-\(region)"
        params["locale"] = NetworkManager.shared.getLocale()
        params["access_token"] = NetworkManager.shared.getAccessToken()
        
        // Create URL Components
        let urlString = "\(NetworkManager.shared.getBlizzardBaseAPI(region: region))/data/wow/realm/index"
        var components = URLComponents(string: urlString)
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        queryItems = queryItems.filter{ !$0.name.isEmpty }
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        // Create POST request.
        if let url = components?.url {
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
        do {
            let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
            
            // Remove any exisiting realms for the region from Core Data.
            // NEEDED!!!! Otherwise, we try to edit too many realms at once.
            Realm.removeAllRealms(forRegion: region, context: managedObjectContext)
            
            // Add the realms to core data.
            let decodedRealmData = try JSONDecoder().decode(Realms.self, from: data)
            for realm in decodedRealmData.realms {
                self.importRealm(withData: realm, region: region, context: managedObjectContext)
            }
            try managedObjectContext.save()
            
            // Set the next realm fetch date to now + 7 days.
            let calendar = Calendar.current
            let nextRefreshDate = calendar.date(byAdding: .day, value: 3, to: Date())
            UserDefaultsHelper.set(value: nextRefreshDate, forKey: "\(realmRefreshDate)\(region)")
            
            return true
        } catch {
            print(error)
            return false
        }
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
    public struct Realms: Codable {
        var realms: [RealmData]
    }
}

struct RealmData: Codable {
    var name: String
    var id: Int32
    var slug: String
}
