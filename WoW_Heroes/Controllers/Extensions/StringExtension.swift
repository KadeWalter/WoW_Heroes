//
//  StringExtension.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/8/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

extension String {
    func onlyContainsLetters() -> Bool {
        do {
        let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
            if regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil {
                 return false

            } else {
                return true
            }
        } catch {
            return false
        }
    }
}
