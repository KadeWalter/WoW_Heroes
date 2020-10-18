//
//  SCGuildAchievements.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

class SCGuildAchievements {
    class func getGuildAchievements(forGuild guild: Guild, completion: @escaping (Bool) -> Void) {
        // Create URL Components
        let urlString = "\(NetworkManager.getBlizzardBaseApiUrl(region: guild.realm.region))/data/wow/guild/\(guild.realm.slug)/\(guild.slug)/achievements"
        
        // Create POST request.
        if let url = NetworkManager.getBlizzardApiTaskUrl(forRegion: guild.realm.region, withUrlString: urlString, forNamespace: .profile) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            NetworkManager.executeTask(forRequest: request, serviceCallName: "GetGuildAchievements") { data, response, error in
                if error == nil {
                    completion(processGuildAchievements(data: data, guildInfo: guild))
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private class func processGuildAchievements(data: Data?, guildInfo: Guild) -> Bool {
        guard let d = data, let guildAchieves = try? JSONDecoder().decode(GuildAchievementResponseData.self, from: d) else { return false }
        let managedObjectContext = WHNSManagedObject.WHManagedObjectContext()
        var success: Bool = false
        
        managedObjectContext.performAndWait {
            do {
                // Import the roster and save to managed object context
                guard let guild = Guild.fetchGuild(withId: guildInfo.id, name: guildInfo.name, context: managedObjectContext) else { return }
                for guildAchieve in guildAchieves.recent_events {
                    guard let achieve = GuildAchievement.createWithoutInsert(context: managedObjectContext) else { return }

                    achieve.name = guildAchieve.achievement.name
                    achieve.timestamp = guildAchieve.timestamp
                    
                    // We really only want to show any guild achievements within the last month
                    let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -4, to: Date())?.timeIntervalSince1970
                    if achieve.timestamp > Int64(oneMonthAgo ?? 0) * 1000 {
                        if let achievementExists = GuildAchievement.fetchGuildAchievement(achievementName: achieve.name) {
                            achievementExists.updateGuildAchievement(fromGuildAchievement: achieve)
                            achievementExists.guild = guild
                        } else {
                            achieve.insert(intoContext: managedObjectContext)
                            achieve.guild = guild
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

extension SCGuildAchievements {
    struct GuildAchievementResponseData: Codable {
        var recent_events: [GuildAchievementData]
    }
    
    struct GuildAchievementData: Codable {
        var achievement: AchievementData
        var timestamp: Int64
    }
    
    struct AchievementData: Codable {
        var name: String
    }
}
