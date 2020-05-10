//
//  MainTabBarController.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol PlayerPresenting {
    func presentPlayer(withEpisode episode: Episode)
}

class MainTabBarController: UITabBarController, PlayerPresenting, PlayerViewDelegate {
    private var playerController: PlayerController!
    private weak var playerView: PlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.tintColor = .purple
        view.backgroundColor = .white
        
        setupViewControllers()
    }
    
    // MARK: - PlayerViewDelegate
    func dissmis() {
        self.playerView?.isDissmised = true
        performShowingTabBarWithAnimation()
    }
    
    func enlarge() {
        self.playerView?.isDissmised = false
        performHiddingTabBarWithAnimation()
    }
    
    // MARK: - PlayerPresenting
    func presentPlayer(withEpisode episode: Episode) {
        if playerController == Optional.none {
            playerController = PlayerController()
            playerController.episode = episode
            addChild(playerController)
            let playerView = playerController.view.subviews.first! as! PlayerView
            playerView.delegate = self
            playerView.frame = tabBar.frame
            view.insertSubview(playerView, belowSubview: tabBar)
            self.playerView = playerView
        }
        enlarge()
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
