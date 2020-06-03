//
//  FavoriteButtonItem.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

final class FavoriteButtonItem: UIBarButtonItem {
    var isFavorite: Bool! {
        didSet {
            if self.isFavorite {
                self.image = UIImage(named: "heart")!
            } else {
                self.title = "Favorite"
                self.image = nil
            }
        }
    }
}
