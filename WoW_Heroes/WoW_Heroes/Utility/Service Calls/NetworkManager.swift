//
//  NetworkManager.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 2/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    let blizzardBaseAPI: String
    
    private init() {
        blizzardBaseAPI = "https://%@.api.blizzard.com"
    }
    
    func accessTokenNeedsRefreshed() {
        // Check if the access token needs refreshed. If it does, get a new one.
        // TODO: - Remove print statements.
        if let accessTokenEpiration = UserDefaults.standard.value(forKey: "BlizzardAccessExpiration") as? Date {
            if Date() < accessTokenEpiration {
                return
            }
        }
        updateToken()
    }
    
    func updateToken() {
        SCAccessToken.getAccessToken()
    }
    
    func getBlizzardBaseAPI(region: String) -> String {
        return String(format: blizzardBaseAPI, region)
    }
    
    func getAccessToken() -> String {
        // Return the current access token from User Defaults.
        return UserDefaults.standard.string(forKey: "BlizzardAccessToken") ?? ""
    }
    
    func getLocale() -> String {
        // TODO: - re-enable this. doesnt work on simulator
//        let language = Locale.preferredLanguages[0]
//        language = language.replacingOccurrences(of: "-", with: "_")
//        return language
        return "en_US"
    }
}
