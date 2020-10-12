//
//  StringExtension.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/8/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import Foundation

extension String {
    func containsOnlyLettersAndWhitespace() -> Bool {
        let allowed = CharacterSet.letters.union(.whitespaces)
        return unicodeScalars.allSatisfy(allowed.contains)
    }
}
