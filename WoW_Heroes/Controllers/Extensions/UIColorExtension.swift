//
//  UIColorExtension.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/9/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b: CGFloat
        let hexTrimmed = hex.trimmingCharacters(in: .whitespaces).lowercased()
        
        if hexTrimmed.hasPrefix("#") {
            let start = hexTrimmed.index(hexTrimmed.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
        return
    }
}
