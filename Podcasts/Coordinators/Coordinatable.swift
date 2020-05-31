//
//  Coordinating.swift
//  Podcasts
//
//  Created by Олег Черных on 13/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//
import UIKit

protocol Coordinatable {
    var child: Coordinatable! { get set }
    var navigationController: UINavigationController! { get set }
}
