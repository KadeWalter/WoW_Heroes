//
//  SCGuildEvents.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

class SCGuildEvents {
    class func getGuildEvents(forGuild guild: Guild, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: guild.realm.region))/data/wow/guild/\(guild.realm.slug)/\(guild.slug)/activity"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: guild.realm.region, withUrlString: urlString, forNamespace: .profile) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetGuildEvents") { data, response, error in
                if error == nil {
                    completion(processGuildEvents(data: data, guildInfo: guild))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processGuildEvents(data: Data?, guildInfo: Guild) -> Bool {
        guard let data = data, let guildEvents = try? JSONDecoder().decode(GuildEventData.self, from: data) else { return false }
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        var success: Bool = false
        
        managedObjectContext.performAndWait {
            do {
                // Import the roster and save to managed object context
                guard let guild = Guild.fetchGuild(withId: guildInfo.id, name: guildInfo.name, context: managedObjectContext) else { return }
                for guildEvent in guildEvents.activities {
                    guard let event = GuildEvent.createWithoutInsert(context: managedObjectContext) else { return }
                    
                    if let characterAchievement = guildEvent.character_achievement {
                        event.character = characterAchievement.character.name
                        event.eventName = characterAchievement.achievement.name
                        event.type = guildEvent.activity.type
                        event.timestamp = guildEvent.timestamp
                        
                        guard let charName = event.character else { return }
                        if let achievementExists = GuildEvent.fetchCharacterAchievement(achievementName: event.eventName, characterName: charName, type: event.type) {
                            achievementExists.updateCharacterAchievement(fromEventInfo: event)
                            achievementExists.guild = guild
                        } else {
                            event.insert(intoContext: managedObjectContext)
                            event.guild = guild
                        }
                    } else if let encounter = guildEvent.encounter_completed {
                        event.difficulty = encounter.mode.name
                        event.eventName = encounter.encounter.name
                        event.type = guildEvent.activity.type
                        event.timestamp = guildEvent.timestamp
                        
                        guard let diff = event.difficulty else { return }
                        if let encounterExists = GuildEvent.fetchEncounter(encounterName: event.eventName, difficulty: diff, type: event.type) {
                            encounterExists.updateGuildEncounter(fromEventInfo: event)
                            encounterExists.guild = guild
                        } else {
                            event.insert(intoContext: managedObjectContext)
                            event.guild = guild
                        }
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

extension SCGuildEvents {
    private struct GuildEventData: Codable {
        var activities: [ActivityData]
    }
    
    private struct ActivityData: Codable {
        var character_achievement: CharacterActivityData?
        var encounter_completed: EncounterCompletedData?
        var activity: ActivityType
        var timestamp: Int64
    }
    
    private struct ActivityType: Codable {
        var type: String
    }
    
    // Character Activity Structs
    private struct CharacterActivityData: Codable {
        var character: CharacterData
        var achievement: AchievementData
    }
    
    private struct CharacterData: Codable {
        var name: String
    }
    
    private struct AchievementData: Codable {
        var name: String
    }
    
    // Encounter Structs
    private struct EncounterCompletedData: Codable {
        var encounter: EncounterData
        var mode: EncounterMode
    }
    
    private struct EncounterData: Codable {
        var name: String
    }
    
    private struct EncounterMode: Codable {
        var name: String
    }
}
