//
//  COMAccessToken.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 2/9/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

final class SCAccessToken {
    
    private static var refreshTask: DispatchWorkItem?
    
    /**
     Using Blizzards Client Credential Flow, get an access token used for making API calls.
     Call for token will contain access token and expiration time (in seconds).
     Access token and expiration time are stored in user defaults.
     Subsequent API calls should check if access token is expired, and if so, request a new token.
     */
    class func getAccessToken() {
        // Get the client information.
        var clientId = ""
        var secret = ""
        let plistDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            plistDict = NSDictionary(contentsOfFile: path)
            let clientInfo = plistDict!["ClientInformation"] as? [String : String]
            clientId = clientInfo?["ClientId"] ?? ""
            secret = clientInfo?["ClientSecret"] ?? ""
        }
        
        let loginString = "\(clientId):\(secret)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            return
        }
        let encodedLogin = loginData.base64EncodedString()
        
        // Create POST request.
        let url = URL(string: "https://us.battle.net/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Basic Auth with ClientId and ClientSecret
        request.setValue("Basic \(encodedLogin)", forHTTPHeaderField: "Authorization")
        
        // Post Data is just the grant_type for blizzard client credentials flow.
        let postData = NSMutableData(data: "grant_type=client_credentials".data(using: .utf8) ?? Data())
        request.httpBody = postData as Data
        
        // Form data. Not actually mutli-part form data, as stated in Blizzard API docs.
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // This call is important, so we need it to finish before we continue code.
        // Create a semaphore to wait for this call to finish.
        let semaphore = DispatchSemaphore(value: 0)
        
        NetworkManager.executeTask(forRequest: request, serviceCallName: "GetAccessToken") { data, response, error in
            if error == nil {
                self.processAccessToken(data: data)
            } else {
                print(error as Any)
            }
            semaphore.signal()
        }
        // Wait for the semaphore to signal so we know we have the token before entering the app.
        semaphore.wait()
    }
    
    private class func processAccessToken(data: Data?) {
        guard let data = data else { return }
        var accessToken: AccessToken
        // Decode and store the access token.
        do {
            accessToken = try JSONDecoder().decode(AccessToken.self, from: data)
        } catch {
            accessToken = AccessToken(token_type: "", access_token: "", expires_in: 0)
            print("Unable to decode access token.")
        }
        UserDefaultsHelper.set(value: accessToken.access_token, forKey: udBlizzardAccessToken)
        UserDefaultsHelper.set(value: Date().addingTimeInterval(accessToken.expires_in), forKey: udBlizzardAccessTokenExpiration)
    }
}

extension SCAccessToken {
    private struct AccessToken: Codable {
        var token_type: String
        var access_token: String
        var expires_in: TimeInterval
    }
}
