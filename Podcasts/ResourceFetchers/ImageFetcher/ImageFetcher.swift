//
//  ImageFetcher.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

final class ImageFetcher: ImageFetching {
    func fetchImage(withImageUrl imageUrl: URL) -> Promise<UIImage> {
        return Promise { (resolver) in
            AF.request(imageUrl).response { (dataResponse) in
                if let _ = dataResponse.error {
                    resolver.reject(ImageServicingError.ISError)
                    return
                }
                
                if let data = dataResponse.data, let image = UIImage(data: data) {
                    resolver.resolve(.fulfilled(image))
                } else {
                    resolver.reject(ImageServicingError.ISError)
                }
            }
        }
    }
}
