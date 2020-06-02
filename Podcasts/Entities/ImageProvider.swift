//
//  ImageProducer.swift
//  Podcasts
//
//  Created by Олег Черных on 02/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

struct ImageProvidingOption {
    var imageSize: CGSize
    var scale: CGFloat
}

struct ImageDescriptor: Hashable {
    var imageSize: CGSize
    var url: URL
    
    func hash(into hasher: inout Hasher) {
        fatalError("Not implemented")
    }
}

final class ImageProvider {
    private let serviceQueue = DispatchQueue(
        label: "image.provider.queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    private let fetcher: ImageFetching
    private var cache: AnyCache<ImageDescriptor, UIImage>?
    init(imageFetcher fetcher: ImageFetching, cache: AnyCache<ImageDescriptor, UIImage>?) {
        self.fetcher = fetcher
        self.cache = cache
    }
    
    func provide(imageWithUrl url: URL, option: ImageProvidingOption) -> Promise<UIImage> {
        fatalError("Not implemented")
    }
}
