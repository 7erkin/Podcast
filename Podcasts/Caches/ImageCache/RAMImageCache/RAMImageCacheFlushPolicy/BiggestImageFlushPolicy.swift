//
//  BiggestImageFlushPolicy.swift
//  Podcasts
//
//  Created by Олег Черных on 17/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

struct BiggestImageFlushPolicy: RAMImageCacheFlushPolicy {
    init(withCacheMemoryLimit availableMegaBytes: Float) {
        fatalError("Not implemented")
    }
    
    func prepareCache(_ cache: inout [URL : UIImage], forCachingImage cachingImage: UIImage) {
        fatalError("Not implemented")
    }
    
    func cached(_ image: UIImage, withUrl url: URL) {
        fatalError("Not implemented")
    }
}
