//
//  EnlargeAnimator.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

class EnlargeAnimator: AppPlayerViewAnimator {
    func invoke(forAppPlayerView view: AppPlayerView) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: {
                view.isDissmised = false
            },
            completion: nil
        )
    }
}
