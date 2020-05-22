//
//  DissmisAnimator.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class DissmisAnimator: AppPlayerViewAnimator {
    func invoke(forAppPlayerView view: AppPlayerView) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                view.isDissmised = true
            },
            completion: nil
        )
    }
}
