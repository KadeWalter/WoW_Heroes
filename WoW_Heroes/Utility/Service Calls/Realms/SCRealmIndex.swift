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
        let serviceCallName = "GetRealms"
        
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
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response, error == nil else {
                    print(error?.localizedDescription ?? "No realm data retreived.")
                    return
                }
                
                NetworkManager.printServiceCallReturnStatus(fromResponse: response, forServiceCall: serviceCallName)
                
                do {
                    let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
                    
                    // Remove any exisiting realms for the region from Core Data.
                    // NEEDED!!!! Otherwise, we try to edit too many realms at once.
                    Realm.removeAllRealms(forRegion: region, context: managedObjectContext)
                    
                    // Add the realms to core data.
                    let decodedRealmData = try JSONDecoder().decode(Realms.self, from: data)
                    for realm in decodedRealmData.realms {
                        self.processRealmData(withData: realm, region: region, context: managedObjectContext)
                    }
                    try managedObjectContext.save()
                    
                    // Set the next realm fetch date to now + 7 days.
                    let calendar = Calendar.current
                    let nextRefreshDate = calendar.date(byAdding: .day, value: 7, to: Date())
                    UserDefaultsHelper.set(value: nextRefreshDate, forKey: realmRefreshDate)
                    
                    completion(true)
                } catch {
                    print(error)
                    completion(false)
                }
                completion(false)
            }
            task.resume()
        }
    }
    
    private class func processRealmData(withData realmData: RealmData, region: String, context: NSManagedObjectContext) {
        guard let realm = Realm.createWithoutInsert(context: context) else { return }
        realm.name = realmData.name
        realm.slug = realmData.slug
        realm.id = realmData.id
        realm.region = region
        
        if let existingRealm = Realm.fetchRealm(withId: Int(realmData.id), region: region, context: context) {
            // If the realm already exists, just update it.
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
