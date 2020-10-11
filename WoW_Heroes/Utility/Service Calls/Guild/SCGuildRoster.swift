//
//  SCGuildRoster.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/11/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

final class SCGuildRoster {
    
    class func getRoster(region: String, guildSlug: String, realmSlug: String, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: region))/data/wow/guild/\(realmSlug)/\(guildSlug)/roster"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: region, withUrlString: urlString, forNamespace: .profile) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetGuildRoster") { data, response, error in
                if error == nil {
                    guard let data = data else { completion(false); return }
                    completion(processRosterData(data: data))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processRosterData(data: Data?) -> Bool {
        guard let data = data, let rosterInfo = try? JSONDecoder().decode(RosterResponseData.self, from: data) else { return false }
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        var success: Bool = false
        
        managedObjectContext.performAndWait {
            do {
                // Import the roster and save to managed object context
                guard let guild = Guild.fetchGuild(withId: rosterInfo.guild.id, name: rosterInfo.guild.name, context: managedObjectContext) else { return }
                for rosterMember in rosterInfo.members {
                    guard let member = GuildRosterMember.createWithoutInsert(context: managedObjectContext), let charClass = CharacterClass.fetchCharacterClass(withId: rosterMember.character.playable_class.id, context: managedObjectContext) else { return }
                    member.level = rosterMember.character.level
                    member.name = rosterMember.character.name
                    member.rank = rosterMember.rank
                    
                    if let memberExists = GuildRosterMember.fetchGuildMember(withName: member.name, guildName: member.guild.name) {
                        // Update the character class object if it already exists.
                        memberExists.updateGuildRosterMember(fromMember: member)
                        memberExists.guild = guild
                        memberExists.playableClass = charClass
                    } else {
                        // Otherwise insert it
                        member.insert(intoContext: managedObjectContext)
                        member.guild = guild
                        member.playableClass = charClass
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

extension SCGuildRoster {
    private struct RosterResponseData: Codable {
        var members: [MemberData]
        var guild: GuildData
    }
    
    private struct MemberData: Codable {
        var character: CharacterData
        var rank: Int16
    }
    
    private struct CharacterData: Codable {
        var name: String
        var level: Int16
        var playable_class: ClassData
    }
    
    private struct ClassData: Codable {
        var id: Int16
    }
    
    private struct GuildData: Codable {
        var name: String
        var id: Int64
    }
}
