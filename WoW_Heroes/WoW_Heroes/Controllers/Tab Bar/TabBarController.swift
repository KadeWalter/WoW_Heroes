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

		tabBar.tintColor = .blue
		setupTabBar()
	}
	
	func setupTabBar() {
		// create home screen/character select view controller
		let homescreenVC = UINavigationController(rootViewController: HomeTableViewController())
		homescreenVC.tabBarItem.image = UIImage(systemName: "paperplane.fill")
		// create pve view controller
		let pveVC = UINavigationController(rootViewController: PVETableViewController())
		pveVC.tabBarItem.image = UIImage(systemName: "bolt.fill")
		// create gear view controller
		let gearVC = UINavigationController(rootViewController: GearTableViewController())
		gearVC.tabBarItem.image = UIImage(systemName: "bell.fill")
		// create settings view controller
		let settingsVC = UINavigationController(rootViewController: SettingsTableViewController())
		settingsVC.tabBarItem.image = UIImage(systemName: "video.fill")

		// add view controllers to tab bar
		viewControllers = [homescreenVC, pveVC, gearVC, settingsVC]
	}
}
