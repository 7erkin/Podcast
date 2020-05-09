//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .purple
        view.backgroundColor = .white
        
        setupViewControllers()
    }
    
    // MARK: - Setup Functions
    fileprivate func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: UIImage(named: "search")!),
            generateNavigationController(with: ViewController(), title: "Favorites", image: UIImage(named: "favorites")!),
            generateNavigationController(with: ViewController(), title: "Downloads", image: UIImage(named: "downloads")!)
        ]
    }
    
    // MARK: - Helper Functions
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
