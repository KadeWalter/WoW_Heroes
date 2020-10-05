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
	
    private func setupTabBar() {
		// create home screen/character select view controller
		let homescreenVC = UINavigationController(rootViewController: HomeTableViewController())
		homescreenVC.tabBarItem.image = UIImage(systemName: "paperplane.fill")

		// add view controllers to tab bar
		viewControllers = [homescreenVC]
	}
}
