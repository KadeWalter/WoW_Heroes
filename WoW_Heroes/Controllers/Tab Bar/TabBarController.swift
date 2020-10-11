//
//  ViewController.swift
//  WoW_Heroes
//
//  Created by Kade Walter on 1/17/20.
//  Copyright © 2020 Kade Walter. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()
        tabBar.tintColor = UIColor.init(hex: UserDefaultsHelper.getValue(forKey: udAppTheme) as? String ?? "")
		setupTabBar()
	}
	
    private func setupTabBar() {
		// create home screen/character select table view controller
		let homescreenVC = UINavigationController(rootViewController: HomeTableViewController())
		homescreenVC.tabBarItem.image = UIImage(systemName: "paperplane.fill")
        
        // create settings table view controller
        let settingsVC = UINavigationController(rootViewController: SettingsTableViewController())
        settingsVC.tabBarItem.image = UIImage(systemName: "video.fill")

		// add view controllers to tab bar
		viewControllers = [homescreenVC, settingsVC]
	}
}
