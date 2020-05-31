//
//  ImageDownloading.swift
//  Podcasts
//
//  Created by Олег Черных on 22/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

struct ImageServicingError: Error {}

protocol ImageFetching: class {
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage>
}
