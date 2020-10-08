//
//  COMCharacter.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 4/2/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation
import CoreData

final class SCCharacterProfile {
    
    class func getCharacter(region: String, characterName: String, realm: Realm, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: region))/profile/wow/character/\(realm.slug)/\(characterName.lowercased())"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: region, withUrlString: urlString, forNamespace: .profile) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetCharacter") { data, response, error in
                if error == nil {
                    guard let data = data else { completion(false); return }
                    completion(processCharacterData(data: data, realm: realm))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processCharacterData(data: Data?, realm: Realm) -> Bool {
        guard let data = data, let characterInfo = try? JSONDecoder().decode(CharacterProfileResponseData.self, from: data) else { return false }
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        var success: Bool = false
        
        managedObjectContext.performAndWait {
            do {
                // Import the character
                self.importCharacter(characterData: characterInfo, realm: realm, context: managedObjectContext)
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
    
    private class func importCharacter(characterData: CharacterProfileResponseData, realm: Realm, context: NSManagedObjectContext) {
        // TODO: - Also create without insert guild. check if guild exists. if it does, fetch the guild and add it to the character. otherwise create the guild and then add it to the character.
        guard let character = Character.createWithoutInsert(context: context), let realmObj = Realm.fetchRealm(withId: Int(realm.id), region: realm.region, context: context), let charClass = CharacterClass.createWithoutInsert(context: context), let guild = Guild.createWithoutInsert(context: context) else { return }
        
        // Character entity information
        character.achievementPoints = Int32(characterData.achievement_points)
        character.activeSpec = characterData.active_spec.name
        character.activeTitle = characterData.active_title?.name
        character.averageIlvl = Int16(characterData.average_item_level)
        character.equippedIlvl = Int16(characterData.equipped_item_level)
        character.faction = characterData.faction.name
        character.gender = characterData.gender.name
        character.id = Int64(characterData.id)
        character.level = Int16(characterData.level)
        character.name = characterData.name
        character.race = characterData.race.name
        
        // Class entity information
        charClass.id = Int16(characterData.character_class.id)
        charClass.name = characterData.character_class.name
        
        // Guild entity informtion
        if let guildInfo = characterData.guild {
            guild.id = Int64(guildInfo.id)
            guild.name = guildInfo.name
            guild.faction = guildInfo.faction.name
        }
        
        
        // Check if the characters class already exists. if it does, add the character. Otherwise make it and add the character.
        var classExists: CharacterClass?
        if let existingClass = CharacterClass.fetchCharacterClass(withId: charClass.id, name: charClass.name, context: context) {
            classExists = existingClass
        } else {
            charClass.insert(intoContext: context)
            classExists = charClass
        }
        
        // Check if the characters guild already exists. if it does, add the character. Otherwise make it and add the character.
        // Insert the guild to the realm if needed as well.
        var guildExists: Guild?
        if let existingGuild = Guild.fetchGuild(withId: guild.id, name: guild.name, context: context) {
            guildExists = existingGuild
        } else {
            // Make sure we got the guild info
            if let _ = characterData.guild {
                guild.insert(intoContext: context)
                guildExists = guild
            }
        }
        
        // Check if the characters guild already exists. if it does, add the character. Otherwise make it and add the character.
        // Insert the guild to the realm if needed as well.
        if let existingCharacter = Character.fetchCharacter(withId: character.id, name: character.name, context: context) {
            existingCharacter.updateCharacter(fromCharacter: character)
            if let g = guildExists, let c = classExists {
                existingCharacter.guild = g
                existingCharacter.characterClass = c
                if !g.characters.contains(existingCharacter) {
                    g.characters.insert(character)
                }
                if !c.characters.contains(existingCharacter) {
                    c.characters.insert(character)
                }
            }
        } else {
            character.insert(intoContext: context)
            if let g = guildExists, let c = classExists {
                character.guild = g
                character.characterClass = c
                realmObj.guilds.insert(g)
                g.characters.insert(character)
                c.characters.insert(character)
            }
            realmObj.characters.insert(character)
        }
    }
}

extension SCCharacterProfile {
    struct CharacterProfileResponseData: Codable {
        var id: Int
        var name: String
        var gender: CharacterGenderInfo
        var faction: CharacterFactionInfo
        var race: CharacterRaceInfo
        var character_class: CharacterClassInfo
        var active_spec: CharacterActiveSpec
        var guild: CharacterGuildInfo?
        var level: Int
        var achievement_points: Int
        var average_item_level: Int
        var equipped_item_level: Int
        var active_title: CharacterActiveTitleInfo?
    }
    
    struct CharacterGenderInfo: Codable {
        var type: String
        var name: String
    }
    
    struct CharacterFactionInfo: Codable {
        var type: String
        var name: String
    }
    
    struct CharacterRaceInfo: Codable {
        var name: String
        var id: Int
    }
    
    struct CharacterClassInfo: Codable {
        var name: String
        var id: Int
    }
    
    struct CharacterActiveSpec: Codable {
        var name: String
        var id: Int
    }
    
    struct CharacterGuildInfo: Codable {
        var name: String
        var id: Int
        var faction: CharacterFactionInfo
        
    }
    
    struct CharacterActiveTitleInfo: Codable {
        var name: String
        var id: Int
    }
}
