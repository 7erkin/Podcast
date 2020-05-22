//
//  ImageService.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

class ImageFetcherProxi: ImageFetching {
    private let cache: ImageCaching
    private let fetcher: ImageFetching
    init(cache: ImageCaching, fetcher: ImageFetching) {
        self.cache = cache
        self.fetcher = fetcher
    }
    // MARK: - ImageFetching implementation
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return Promise { resolver in
            firstly {
                cache.hasImage(withImageUrl: imageUrl)
            }.then { hasImage -> Promise<UIImage> in
                return hasImage ?
                    self.cache.getImage(withImageUrl: imageUrl) :
                    self.fetchImageFromService(withImageUrl: imageUrl)
            }.done { image in
                resolver.resolve(.fulfilled(image))
            }.catch { error in
                if error is NetworkError { resolver.reject(error) }
                
                if error is CacheError {
                    firstly {
                        self.fetcher.fetchImage(withImageUrl: imageUrl)
                    }.done { image in
                        resolver.resolve(.fulfilled(image))
                    }.catch { _ in
                        resolver.reject(ServiceError())
                    }
                }
            }
        }
    }
    // MARK: - helpers
    fileprivate func fetchImageFromService(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return firstly {
            self.fetcher.fetchImage(withImageUrl: imageUrl)
        }.then { image -> Promise<UIImage> in
            self.cache.cache(image, withImageUrl: imageUrl)
            return Promise { $0.resolve(.fulfilled(image)) }
        }
    }
}
