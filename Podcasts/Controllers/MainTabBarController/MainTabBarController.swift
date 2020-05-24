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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .purple
        view.backgroundColor = .white
        
        setupViewControllers()
        setup()
        setupAppPlayerControllerAnimations()
    }
    
    private func setupAppPlayerControllerAnimations() {
        let animatorFactory = AppPlayerViewAnimatorFactory()
        appPlayerController.enlargeAnimator = EnlargeAnimatorEnhancer(self, animatorFactory.createAnimation(.enlarge))
        appPlayerController.dissmisAnimator = DissmisAnimatorEnhancer(self, animatorFactory.createAnimation(.dissmis))
        appPlayerController.presentAnimator = PresentAnimatorEnhancer(self, animatorFactory.createAnimation(.present))
    }
    
    private func setup() {
        let player = Player.shared
        mediaCenterPlayerController = .init()
        mediaCenterPlayerController.player = player
        
        lockScreenPlayerController = .init()
        //lockScreenPlayerController.player = player
        
        appPlayerController = .init()
        appPlayerController.player = player
    }
    
    func performHiddingTabBarWithAnimation() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseIn],
            animations: {[weak self] in
                self?.tabBar.isHidden = true
            },
            completion: nil
        )
    }
    
    func performShowingTabBarWithAnimation() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.curveEaseIn],
            animations: {[weak self] in
                self?.tabBar.isHidden = false
            },
            completion: nil
        )
    }
    
    // MARK: - Setup Functions
    fileprivate func setupViewControllers() {
//        let layout = UICollectionViewFlowLayout()
//        let favoritesController = FavoritesPodcastController(collectionViewLayout: layout)
        viewControllers = [
            favoritesBarCoordinator.navigationController,
            searchBarCoordinator.navigationController,
            //generateNavigationController(with: ViewController(), title: "Downloads", image: UIImage(named: "downloads")!)
        ]
    }
    
    // MARK: - Helper Functions
    fileprivate func generateNavigationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
