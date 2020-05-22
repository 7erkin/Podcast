//
//  AnimationFactory.swift
//  Podcasts
//
//  Created by Олег Черных on 16/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

enum AppPlayerViewAnimationKind {
    case enlarge
    case dissmis
    case present
}

class AppPlayerViewAnimatorFactory {
    func createAnimation(_ animationKind: AppPlayerViewAnimationKind) -> AppPlayerViewAnimator {
        switch animationKind {
        case .enlarge:
            return EnlargeAnimator()
        case .dissmis:
            return DissmisAnimator()
        case .present:
            return PresentAnimator()
        }
    }
}
