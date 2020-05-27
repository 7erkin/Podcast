//
//  InMemoryImageCacheFlushPolicy.swift
//  Podcasts
//
//  Created by Олег Черных on 17/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol RAMImageCacheFlushPolicy {
    init(withCacheMemoryLimit availableMegaBytes: Float)
    mutating func prepareCache(_ cache: inout [URL:UIImage], forCachingImage cachingImage: UIImage)
    mutating func cached(_ image: UIImage, withUrl url: URL)
}
