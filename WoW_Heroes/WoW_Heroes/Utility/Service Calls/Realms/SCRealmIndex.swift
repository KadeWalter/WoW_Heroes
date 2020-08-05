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
    
    class func getRealms(region: String) {
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
                guard let _ = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                // TODO: - decode realms and add new ones to core data.
            }
            task.resume()
            
        }
    }
}

// Struct for decoding realms.
extension SCRealmIndex {
    public struct Realms: Codable {
        var realms: [Realmy]
    }
    
    struct Realmy: Codable {
        var name: String
        var id: Int
        var slug: String
    }
}
