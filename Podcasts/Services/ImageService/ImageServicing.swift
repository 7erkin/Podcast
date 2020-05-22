//
//  ImageServicing.swift
//  Podcasts
//
//  Created by Олег Черных on 15/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

struct ServiceError: Error {}

struct NetworkError: Error {}

enum ImageServicingError: Error {
    case ISError
}

protocol ImageServicing: class {
    static var shared: ImageServicing { get }
    // Can throw ServiceError and NetworkError
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage>
}
