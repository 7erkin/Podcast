//
//  DownloadBarRootCoordinator.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class DownloadsBarRootCoordinator: RootCoordinator {
    override init() {
        super.init()
        navigationController = UINavigationController()
        navigationController.tabBarItem.image = UIImage(named: "downloads")!
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem.title = "Downloads"
    }
    
    func start() {
        let coordinator = DownloadedEpisodesCoordintator(withNavigationController: navigationController)
        coordinator.start()
        child = coordinator
    }
}
