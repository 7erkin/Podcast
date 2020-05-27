//
//  LatestImageFlishPolicy.swift
//  Podcasts
//
//  Created by Олег Черных on 17/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

struct LatestImageFlushPolicy: RAMImageCacheFlushPolicy {
    fileprivate var cachedUrls: ForwardList<URL> = []
    fileprivate var cacheSize: Float = 0
    fileprivate let cacheMemoryLimit: Float
    init(withCacheMemoryLimit availableMegaBytes: Float) {
        cacheMemoryLimit = availableMegaBytes
    }
    
    mutating func cached(_ image: UIImage, withUrl url: URL) {
        self.cachedUrls.pushBack(value: url)
        self.cacheSize += image.sizeInMB ?? 0
    }
    
    mutating func prepareCache(_ cache: inout [URL : UIImage], forCachingImage cachingImage: UIImage) {
        if let imageSize = cachingImage.sizeInMB, isMemoryLimitIncreased(withImageSize: imageSize) {
            repeat {
                let url = cachedUrls.popFront()!
                let image = cache.removeValue(forKey: url)!
                cacheSize -= image.sizeInMB ?? 0
            } while isMemoryLimitIncreased(withImageSize: imageSize)
        }
    }
    
    fileprivate func isMemoryLimitIncreased(withImageSize imageSize: Float) -> Bool {
        return imageSize + cacheSize > cacheMemoryLimit
    }
}
