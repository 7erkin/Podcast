//
//  ImageService.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

class ImageServiceProxi: ImageServicing {
    private lazy var proxingImageService: ImageServicing = { [unowned self] in
        return self.instantiateProxingServiceInvoker()
    }()
    
    private init() {}
    private let serviceQueue: DispatchQueue = {
        // What do target and AutoreleaseFrequency mean?
        // queue is serial because cache is not thread-safe by contract
        let queue = DispatchQueue(
            label: "image.service.proxi.queue",
            qos: DispatchQoS.userInitiated,
            attributes: [],
            autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem,
            target: nil
        )
        return queue
    }()
    
    var instantiateProxingServiceInvoker: (() -> ImageServicing)!
    var imageCache: ImageCaching!
    
    fileprivate func fetchImageFromService(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return firstly {
            self.proxingImageService.fetchImage(withImageUrl: imageUrl)
        }.then(on: serviceQueue, flags: nil) { (image) -> Promise<UIImage> in
            self.imageCache.cache(image, withImageUrl: imageUrl)
            return Promise { $0.resolve(.fulfilled(image)) }
        }
    }
    
    // MARK: - ImageServicing implementation
    static var shared: ImageServicing = ImageServiceProxi()
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return Promise { resolver in
            firstly {
                imageCache.hasImage(withImageUrl: imageUrl)
            }.then(on: serviceQueue, flags: nil) { (hasImage) -> Promise<UIImage> in
                return hasImage ?
                    self.imageCache.getImage(withImageUrl: imageUrl) :
                    self.fetchImageFromService(withImageUrl: imageUrl)
            }.done(on: serviceQueue, flags: nil) { (image) in
                resolver.resolve(.fulfilled(image))
            }.catch(on: serviceQueue, flags: nil, policy: .allErrors) { (error) in
                if error is NetworkError { resolver.reject(error) }
                
                if error is CacheError {
                    firstly {
                        self.proxingImageService.fetchImage(withImageUrl: imageUrl)
                    }.done(on: self.serviceQueue, flags: nil) { (image) in
                        resolver.resolve(.fulfilled(image))
                    }.catch(on: self.serviceQueue, flags: nil, policy: .allErrors) { (_) in
                        resolver.reject(ServiceError())
                    }
                }
            }
        }
    }
}
