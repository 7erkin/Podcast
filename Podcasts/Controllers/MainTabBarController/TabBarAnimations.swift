//
//  TabBarAnimations.swift
//  Podcasts
//
//  Created by user166334 on 5/29/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

@discardableResult
func invokeAppearingAnimation(withTabBar tabBar: UITabBar) -> UITabBar {
    UIView.animate(
        withDuration: 0.5,
        delay: 0,
        options: [.curveEaseIn],
        animations: { tabBar.isHidden = true },
        completion: nil
    )
    return tabBar
}

@discardableResult
func invokeHiddingAnimation(withTabBar tabBar: UITabBar) -> UITabBar {
    UIView.animate(
        withDuration: 0.5,
        delay: 0,
        options: [.curveEaseIn],
        animations: { tabBar.isHidden = false },
        completion: nil
    )
    return tabBar
}
