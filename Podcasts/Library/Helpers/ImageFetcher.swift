//
//  ImageFetcher.swift
//  Podcasts
//
//  Created by Олег Черных on 24/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class ImageFetcher {
    typealias ImageFetcherResult = Result<UIImage, ErrorKind>
    struct Handler {
        var handleOn: DispatchQueue
        var block: (ImageFetcherResult) -> Void
    }
    private let serviceQueue = DispatchQueue(label: "image.fetcher.queue")
    enum ErrorKind: Error {
        case fetchingError
    }
    struct ImageDescriptor: Hashable {
        var imageUrl: URL
        var imageSize: CGSize
        func hash(into hasher: inout Hasher) {
            hasher.combine(imageUrl)
            hasher.combine(imageSize.height)
            hasher.combine(imageSize.width)
        }
        
        static func == (lhs: ImageDescriptor, rhs: ImageDescriptor) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }
    
    private var pendingHandlers: [ImageDescriptor:[Handler]] = [:]
    private let cache = Cache<ImageDescriptor, UIImage>()
    private init() {}
    static let shared = ImageFetcher()
    func fetch(imageUrl: URL, withImageSize imageSize: CGSize, completionHandler: Handler) {
        serviceQueue.async { [weak self] in
            let imageDescriptor = ImageDescriptor(imageUrl: imageUrl, imageSize: imageSize)
            // if image has already been cached
            if let image = self?.cache[imageDescriptor] {
                completionHandler.handleOn.async {
                    completionHandler.block(.success(image))
                }
                return
            }
            // already have pendingHandlers and it means that dataTask has being performed
            if self?.pendingHandlers[imageDescriptor]?.isEmpty == false {
                self?.pendingHandlers[imageDescriptor]?.append(completionHandler)
                return
            } else {
                self?.pendingHandlers[imageDescriptor] = [completionHandler]
            }
            
            let request = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5.0)
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                if let _ = error {
                    self?.firePendingHandlers(forImageDescriptor: imageDescriptor, .failure(.fetchingError))
                    return
                }
                
                guard
                    let response = response as? HTTPURLResponse,
                    let data = data
                else {
                    self?.firePendingHandlers(forImageDescriptor: imageDescriptor, .failure(.fetchingError))
                    return
                }
                
                if !(200...299).contains(response.statusCode) {
                    self?.firePendingHandlers(forImageDescriptor: imageDescriptor, .failure(.fetchingError))
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let image = downsample(imageData: data, to: imageSize, scale: UITraitCollection.current.displayScale)
                    self?.serviceQueue.async {
                        self?.cache.insert(imageDescriptor, image)
                    }
                    self?.firePendingHandlers(forImageDescriptor: imageDescriptor, .success(image))
                }
            }.resume()
        }
    }
    
    private func firePendingHandlers(forImageDescriptor descriptor: ImageDescriptor, _ value: ImageFetcherResult) {
        serviceQueue.async { [weak self] in self?.pendingHandlers.removeAndFire(forKey: descriptor, value) }
    }
}

extension Dictionary where Key == ImageFetcher.ImageDescriptor, Value == [ImageFetcher.Handler] {
    mutating func removeAndFire(forKey key: ImageFetcher.ImageDescriptor, _ value: ImageFetcher.ImageFetcherResult) {
        self.removeValue(forKey: key)?.forEach { handler in
            handler.handleOn.async { handler.block(value) }
        }
    }
}
