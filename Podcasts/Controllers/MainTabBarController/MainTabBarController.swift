//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class MainTabBarController: UITabBarController {
    private var appPlayerController: AppPlayerController!
    private var mediaCenterPlayerController: MediaCenterPlayerController!
    private var lockScreenPlayerController: LockScreenPlayerController!
    private lazy var searchBarCoordinator: SearchBarRootCoordinator = {
        let coordinator = SearchBarRootCoordinator()
        coordinator.start()
        return coordinator
    }()
    
    private lazy var favoritesBarCoordinator: FavoritesBarRootCoordinator = {
        let coordinator = FavoritesBarRootCoordinator()
        coordinator.start()
        return coordinator
    }()
    
    private lazy var downloadsBarCoordinator: DownloadsBarRootCoordinator = {
        let coordinator = DownloadsBarRootCoordinator()
        coordinator.start()
        return coordinator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .purple
        view.backgroundColor = .white
        
        setupRootViewControllers()
        setupPlayerControllers()
    }
    // MARK :- setup functions
    private func setupAppPlayerViewController() {
        appPlayerController = .init()
        appPlayerController.player = Player.shared
        appPlayerController.view.frame = tabBar.frame
        view.insertSubview(appPlayerController.view, belowSubview: tabBar)
        appPlayerController.dissmisAnimationInvoker = { [ unowned tabBar = tabBar ] playerView in
            invokeAppearingAnimation(withTabBar: tabBar)
            invokeDissmisAnimation(withAppPlayerView: playerView)
        }
        appPlayerController.enlargeAnimationInvoker = { [ unowned tabBar = tabBar ] playerView in
            invokeHiddingAnimation(withTabBar: tabBar)
            invokeEnlargeAnimation(withAppPlayerView: playerView)
        }
    }
    
    private func setupPlayerControllers() {
        mediaCenterPlayerController = .init()
        mediaCenterPlayerController.player = Player.shared
        lockScreenPlayerController = .init()
        lockScreenPlayerController.player = Player.shared
        setupAppPlayerViewController()
    }
    
    private func setupRootViewControllers() {
        viewControllers = [
            favoritesBarCoordinator.navigationController,
            searchBarCoordinator.navigationController,
            downloadsBarCoordinator.navigationController
        ]
    }
}
