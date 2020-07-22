//
//  AsyncImageView.swift
//  Podcasts
//
//  Created by Олег Черных on 24/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class AsyncImageView: UIImageView {
    typealias LoadingImageCallback = () -> Void
    var imageUrl: URL! {
        didSet {
            loadImageIfAvailable()
        }
    }
    
    private var _frame: CGRect = .zero
    override var frame: CGRect {
        get { return _frame }
        set { _frame = newValue; loadImageIfAvailable() }
    }
    
    var startLoadingImage: LoadingImageCallback?
    var finishLoadingImage: LoadingImageCallback?
    private var defferedImageFetch: DefferedBlock!
    private func loadImageIfAvailable() {
        guard let url = imageUrl, _frame != .zero else { return }
        
        let handler = ImageFetcher.Handler(
            handleOn: DispatchQueue.main,
            block: { [weak self] in
                if self?.imageUrl == url {
                    self?.handleImageLoad($0)
                }
            }
        )
        startLoadingImage?()
        ImageFetcher.shared.fetch(
            imageUrl: url,
            withImageSize: self.frame.size,
            completionHandler: handler
        )
    }
    
    private func handleImageLoad(_ result: ImageFetcher.ImageFetcherResult) {
        finishLoadingImage?()
        switch result {
        case .success(let image):
            self.image = image
        default:
            image = UIImage(named: "appicon")
        }
    }
}
