//
//  COMCharacter.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/2/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

final class SCCharacterProfile {
    
    class func getCharacter(region: String, characterName: String, realm: String) {
        // Access the API to get the character from the Blizzard database.
        // Save the character to core data after decoding.
        // Example call: https://us.api.blizzard.com/profile/wow/character/mal'ganis/Smarmie?namespace=profile-us&locale=en_US&access_token=USWLBsAu2CNOJAElakfc6fpTmv0fLwrJP3
        let baseURL = NetworkManager.shared.getBlizzardBaseAPI(region: region)
        print(baseURL)
    }
}
