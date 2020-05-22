//
//  ImageCache.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

struct CacheError: Error {}

// not thread safe cache
protocol ImageCaching {
    @discardableResult
    func cache(_ image: UIImage, withImageUrl imageUrl: URL) -> Promise<Bool>
    
    func hasImage(withImageUrl imageUrl: URL) -> Promise<Bool>
    
    func getImage(withImageUrl imageUrl: URL) -> Promise<UIImage>
}
