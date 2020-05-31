//
//  DissmisAnimator.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

@discardableResult
func invokeDissmisAnimation(withAppPlayerView view: AppPlayerView) -> AppPlayerView {
    UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.7,
        initialSpringVelocity: 0,
        options: [.curveEaseIn],
        animations: { view.isDissmised = true },
        completion: nil
    )
    return view
}

@discardableResult
func invokeEnlargeAnimation(withAppPlayerView view: AppPlayerView) -> AppPlayerView {
    UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [.curveEaseIn],
        animations: { view.isDissmised = false },
        completion: nil
    )
    return view
}
