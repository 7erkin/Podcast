//
//  DissmisAnimatorEnchancer.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

class DissmisAnimatorEnhancer: AppPlayerViewAnimatorEnhancer {
    var animator: AppPlayerViewAnimator
    weak var mainTabBarController: MainTabBarController?
    
    init(_ tabBarController: MainTabBarController, _ animator: AppPlayerViewAnimator) {
        self.animator = animator
        self.mainTabBarController = tabBarController
    }

    func invoke(forAppPlayerView view: AppPlayerView)
    {
        guard let tabBarController = mainTabBarController else { return }
        tabBarController.performShowingTabBarWithAnimation()
        animator.invoke(forAppPlayerView: view)
    }
}
