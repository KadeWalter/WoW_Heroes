//
//  SCPlayableClasses.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

final class SCPlayableClassees {
    
    class func getClasses(region: String, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: region))/data/wow/playable-class/index"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: region, withUrlString: urlString, forNamespace: .staticNamespace) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetPlayableClasses") { data, response, error in
                if error == nil {
                    guard let data = data else { completion(false); return }
                    completion(processClassData(data: data))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processClassData(data: Data?) -> Bool {
        guard let data = data, let classInfo = try? JSONDecoder().decode(ClassResponseData.self, from: data) else { return false }
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        var success: Bool = false
        
        managedObjectContext.performAndWait {
            do {
                // Import the classes abd save to managed object context
                for classObj in classInfo.classes {
                    guard let charClass = CharacterClass.createWithoutInsert(context: managedObjectContext) else { return }
                    charClass.name = classObj.name
                    charClass.id = classObj.id
                    
                    if let classExists = CharacterClass.fetchCharacterClass(withId: charClass.id) {
                        // Update the character class object if it already exists.
                        classExists.updateCharacterClass(fromCharacterClass: charClass)
                    } else {
                        // Otherwise insert it
                        charClass.insert(intoContext: managedObjectContext)
                    }
                }
                
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                }
                
                success = true
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return success
    }
}

extension SCPlayableClassees {
    private struct ClassResponseData: Codable {
        var classes: [ClassData]
    }
    
    private struct ClassData: Codable {
        var name: String
        var id: Int16
    }
}
