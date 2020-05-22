//
//  ImageDownloading.swift
//  Podcasts
//
//  Created by Олег Черных on 22/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

struct ServiceError: Error {}

struct NetworkError: Error {}

enum ImageServicingError: Error {
    case ISError
}

protocol ImageFetching: class {
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage>
}
