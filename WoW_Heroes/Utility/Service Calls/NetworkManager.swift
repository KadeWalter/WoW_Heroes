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
    
    class func printServiceCallReturnStatus(fromResponse response: URLResponse, forServiceCall serviceCall: String) {
        var printString: String = ""
        if let httpsResponse = response as? HTTPURLResponse {
            printString.append("Network Manager: \n")
            printString.append("\tNetwork Call - \(serviceCall)\n")
            printString.append("\tService Response - \(httpsResponse.statusCode)\n")
            print(printString)
        }
    }
}

// MARK: - Blizzard Access Token and URL Functions
extension NetworkManager {
    func getBlizzardBaseAPI(region: String) -> String {
        return String(format: blizzardBaseAPI, region)
    }
    
    func accessTokenNeedsRefreshed() {
        // Check if the access token needs refreshed. If it does, get a new one.
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
    
    func getAccessToken() -> String {
        // Return the current access token from User Defaults.
        if let token = UserDefaultsHelper.getValue(forKey: "blizzardApiToken") as? String {
            return token
        }
        return ""
    }
    
    func getLocale() -> String {
        // TODO: - re-enable this. doesnt work on simulator
//        let language = Locale.preferredLanguages[0]
//        language = language.replacingOccurrences(of: "-", with: "_")
//        return language
        return "en_US"
    }
}
