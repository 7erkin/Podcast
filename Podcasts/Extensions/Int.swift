//
//  IndexPath.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension Int {
    var toIndexPath: IndexPath {
        return IndexPath(row: self, section: 0)
    }
}
