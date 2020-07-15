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
                if self?.imageUrl != url { return }
                self?.finishLoadingImage?()
                switch $0 {
                case .success(let image):
                    self?.image = image
                default:
                    self?.image = UIImage(named: "appicon")
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
}
