//
//  Spinner.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 9/28/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class Spinner: UIView {
    
    let spinner = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupSpinner()
        animation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func animation() {
        UIView.animate(withDuration: 0.65, delay: 0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: { completed in
            UIView.animate(withDuration: 0.65, delay: 0, options: .curveLinear, animations: {
                self.transform = CGAffineTransform(rotationAngle: 0)
            }, completion: { completed in
                self.animation()
            })
        })
    }
    
    private func setupSpinner() {
        frame = CGRect(x: 0, y: 0, width: 100, height: 100) // set the frame of the view to a small square
        
        let rect = self.bounds // Bounds is the same size as width and height in the frame property
        let circularPath = UIBezierPath(ovalIn: rect) // creates a circular path inside of the rect
        
        spinner.path = circularPath.cgPath
        spinner.fillColor = UIColor.clear.cgColor // sets the uiview color to clear
        // set the spinner color
        spinner.strokeColor = self.traitCollection.userInterfaceStyle == .dark ? UIColor.white.cgColor : UIColor.darkGray.cgColor
        spinner.lineWidth = 7 // how wide is the spinner
        spinner.strokeEnd = 0.4 // how long is the line
        spinner.lineCap = .round // rounded ends on the line
        
        self.layer.addSublayer(spinner)
    }
}
