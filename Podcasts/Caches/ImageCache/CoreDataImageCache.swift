//
//  CoreDataImageCache.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

class CoreDataImageCache: ImageCaching {
    func cache(_ image: UIImage, withImageUrl imageUrl: URL) -> Promise<Bool> {
        fatalError("Not implemented")
    }
    
    func hasImage(withImageUrl imageUrl: URL) -> Promise<Bool> {
        fatalError("Not implemented")
    }
    
    func getImage(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        fatalError("Not implemented")
    }
}
