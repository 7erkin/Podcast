//
//  UISearchController.swift
//  Podcasts
//
//  Created by Олег Черных on 20/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

extension UISearchController {
    var hasSearchText: Bool {
        if let text = self.searchBar.text {
            return text.count != 0
        }
        return false
    }
}
