//
//  NetworkManager.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 2/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

typealias NetworkCompletionBlock = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

enum BlizzardApiNamespaceType: String {
    case profile
    case dynamic
    case staticNamespace = "static"
}

class NetworkManager {
    
    static let blizzardBaseApiUrl = "https://%@.api.blizzard.com"
}

// MARK: - Task Execution Functions
extension NetworkManager {
    class func executeTask(forRequest request: URLRequest, serviceCallName: String, _ completion : @escaping NetworkCompletionBlock) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response {
                printServiceCallReturnStatus(fromResponse: response, forServiceCall: serviceCallName)
            }
            completion(data, response, error)
        }
        task.resume()
    }
    
    class func getBlizzardApiTaskUrl(forRegion region: String, withUrlString urlStr: String, forNamespace namespace: BlizzardApiNamespaceType) -> URL? {
        // Create Params
        var params: [String : String] = [:]
        params["namespace"] = "\(namespace.rawValue)-\(region)"
        params["locale"] = getLocale()
        params["access_token"] = getAccessToken()
        
        // Create URL Components
        let url = URL(string: urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        queryItems = queryItems.filter{ !$0.name.isEmpty }
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        return components?.url
    }
    
    private class func printServiceCallReturnStatus(fromResponse response: URLResponse, forServiceCall serviceCall: String) {
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
    class func getBlizzardBaseApiUrl(region: String) -> String {
        return String(format: blizzardBaseApiUrl, region)
    }
    
    class func accessTokenNeedsRefreshed() {
        // Check if the access token needs refreshed. If it does, get a new one.
        if let accessTokenEpiration = UserDefaults.standard.value(forKey: udBlizzardAccessTokenExpiration) as? Date {
            if Date() < accessTokenEpiration {
                return
            }
        }
        updateToken()
    }
    
    private class func getAccessToken() -> String {
        // Return the current access token from User Defaults.
        if let token = UserDefaultsHelper.getStringValue(forKey: udBlizzardAccessToken) {
            return token
        }
        return ""
    }
    
    private class func getLocale() -> String {
        // TODO: - re-enable this. doesnt work on simulator
//        let language = Locale.preferredLanguages[0]
//        language = language.replacingOccurrences(of: "-", with: "_")
//        return language
        return "en_US"
    }
    
    private class func updateToken() {
        SCAccessToken.getAccessToken()
    }
}
