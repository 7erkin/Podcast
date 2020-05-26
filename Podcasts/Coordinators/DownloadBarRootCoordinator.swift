//
//  DownloadBarRootCoordinator.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class DownloadBarRootCoordinator: RootCoordinator {
    override init() {
        super.init()
        navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(named: "downloads")!
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.title = "Dowloads"
    }
    
    func start() {
        let coordinator = PodcastSearchCoordinator(withNavigationController: navigationController)
        coordinator.start()
        child = coordinator
    }}
