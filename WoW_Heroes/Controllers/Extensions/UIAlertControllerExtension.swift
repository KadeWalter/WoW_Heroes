//
//  UIAlertControllerExtension.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 10/6/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    /**
     Function for presenting the alert controller on the main thread.
     - Parameter vc: is the view controller to present the alert on. Most likely, just send in self.
    */
    func presentAlert(forViewController vc: UIViewController) {
        DispatchQueue.main.async {
            vc.present(self, animated: true, completion: nil)
        }
    }
    
    func addOkayButton() {
        addOkayButton(withHandler: nil)
    }
    
    func addOkayButton(withHandler handler: ((UIAlertAction) -> Void)?) {
        let okayAction = UIAlertAction(title: localizedOkay(), style: .default, handler: handler)
        self.addAction(okayAction)
    }
    
    private func localizedOkay() -> String {
        return NSLocalizedString("Okay", tableName: "GlobalStrings", bundle: .main, value: "okay button title", comment: "okay button title")
    }
}
