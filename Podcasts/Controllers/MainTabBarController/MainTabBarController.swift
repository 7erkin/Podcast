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
//    private var appPlayerController: AppPlayerController!
//    private var mediaCenterPlayerController: MediaCenterPlayerController!
//    private var lockScreenPlayerController: LockScreenPlayerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .purple
        view.backgroundColor = .white
        
        setupRootViewControllers()
//        setupPlayerControllers()
    }
    // MARK :- setup functions
//    private func setupAppPlayerViewController() {
//        appPlayerController = .init()
//        appPlayerController.player = Player.shared
//        appPlayerController.view.frame = tabBar.frame
//        view.insertSubview(appPlayerController.view, belowSubview: tabBar)
//        appPlayerController.dissmisAnimationInvoker = { [ unowned tabBar = tabBar ] playerView in
//            invokeAppearingAnimation(withTabBar: tabBar)
//            invokeDissmisAnimation(withAppPlayerView: playerView)
//        }
//        appPlayerController.enlargeAnimationInvoker = { [ unowned tabBar = tabBar ] playerView in
//            invokeHiddingAnimation(withTabBar: tabBar)
//            invokeEnlargeAnimation(withAppPlayerView: playerView)
//        }
//    }
    
//    private func setupPlayerControllers() {
//        mediaCenterPlayerController = .init()
//        mediaCenterPlayerController.player = Player.shared
//        lockScreenPlayerController = .init()
//        lockScreenPlayerController.player = Player.shared
//        setupAppPlayerViewController()
//    }
    
    private func setupRootViewControllers() {
        viewControllers = [
            createFavoritePodcastsController(),
            createPodcastsSearchController(),
            createDownloadedEpisodesController()
        ]
    }
    
    private func createPodcastsSearchController() -> UIViewController {
        let controller = PodcastsSearchController()
        let viewModel = PodcastsSearchViewModel(podcastFetcher: ServiceLocator.podcastService)
        controller.viewModel = viewModel
        controller.navigationItem.title = "Podcasts"
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem.title = "Search"
        navigationController.tabBarItem.image = UIImage(named: "search")
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    private func createFavoritePodcastsController() -> UIViewController {
        let model = FavoritePodcastsModel(favoritePodcastsStorage: ServiceLocator.favoritePodcastsStorage)
        let viewModel = FavoritePodcastsViewModel(model)
        let controller = FavoritePodcastsController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.viewModel = viewModel
        controller.navigationItem.title = "Favorites"
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem.title = "Favorite"
        navigationController.tabBarItem.image = UIImage(named: "favorites")
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
    
    private func createDownloadedEpisodesController() -> UIViewController {
        let controller = DownloadedEpisodesController()
        let model = DownloadedEpisodesModel(
            recordRepository: ServiceLocator.recordRepository,
            trackListPlayer: Player.shared
        )
        controller.viewModel = DownloadedEpisodesViewModel(model: model)
        controller.navigationItem.title = "Downloads"
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem.title = "Downloads"
        navigationController.tabBarItem.image = UIImage(named: "downloads")
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }
}
