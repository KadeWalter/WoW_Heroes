//
//  FontManager.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 2/12/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class FontManager {
    
    static let shared = FontManager()
    var standardFont: UIFont
    
    private init() {
        standardFont = UIFont.systemFont(ofSize: 16.0)
    }
    
    func standardFontOfSize(size: CGFloat) -> UIFont {
        return standardFont.withSize(size)
    }
}
