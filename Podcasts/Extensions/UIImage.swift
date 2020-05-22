//
//  UIImage.swift
//  Podcasts
//
//  Created by Олег Черных on 22/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

struct ImageBlurAlgorithmError: Error {}

extension UIImage {
    static func blurImage(_ image: UIImage, blurAmount: Int) -> Promise<UIImage> {
        return Promise.value.then(on: DispatchQueue.global(qos: .userInitiated), flags: nil) { (_) -> Promise<UIImage> in
            return Promise { (resolver) in
                if let image = image.blured(blurAmount: blurAmount) {
                    resolver.resolve(.fulfilled(image))
                } else {
                    resolver.reject(ImageBlurAlgorithmError())
                }
            }
        }
    }
    
    func blured(blurAmount: Int) -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurAmount, forKey: kCIInputRadiusKey)
        
        guard let bluredImage = blurFilter?.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: bluredImage)
    }
}
