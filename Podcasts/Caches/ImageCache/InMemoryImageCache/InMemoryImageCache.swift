//
//  ImageInMemoryCache.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

class InMemoryImageCache: ImageCaching {
    private var cache: [URL:UIImage] = [:]
    private var cacheFlushPolicy: InMemoryImageCacheFlushPolicy
    
    init(withFlushPolicy flushPolicy: InMemoryImageCacheFlushPolicy) {
        cacheFlushPolicy = flushPolicy
    }
    
    func cache(_ image: UIImage, withImageUrl imageUrl: URL) -> Promise<Bool> {
        cacheFlushPolicy.prepareCache(&cache, forCachingImage: image)
        cache[imageUrl] = image
        cacheFlushPolicy.cached(image, withUrl: imageUrl)
        return Promise { (resolver) in
            resolver.resolve(.fulfilled(true))
        }
    }
    
    func hasImage(withImageUrl imageUrl: URL) -> Promise<Bool> {
        return Promise { (resolver) in
            let hasImage = cache.index(forKey: imageUrl) != nil
            resolver.resolve(.fulfilled(hasImage))
        }
    }
    
    func getImage(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return Promise { (resolver) in
            if let image = cache[imageUrl] {
                resolver.resolve(.fulfilled(image))
            } else {
                resolver.reject(CacheError())
            }
        }
    }
}

extension UIImage {
    var sizeInMB: Float? {
        let calculate: (Data) -> Float = { Float($0.count * 1000 / (1024 * 1024)) / 1000 }
        if let data = self.jpegData(compressionQuality: 1.0) {
            return calculate(data)
        }
        
        if let data = self.pngData() {
            return calculate(data)
        }
        
        return nil
    }
}
