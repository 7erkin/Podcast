//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class EpisodeCell: UITableViewCell {
    static var service: ImageServicing = {
        let service = ImageServiceProxi.shared
        let typedService = service as! ImageServiceProxi
        typedService.instantiateProxingServiceInvoker = { ImageService.shared }
        typedService.imageCache = InMemoryImageCache(withFlushPolicy: LatestImageFlushPolicy(withCacheMemoryLimit: 50))
        return service
    }()
    
    fileprivate var timer: Timer?
    var episode: Episode! {
        didSet {
            updateViewWithModel()
        }
    }
    
    fileprivate func updateViewWithModel() {
        episodeNameLabel.text = episode.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        publishDateLabel.text = dateFormatter.string(from: episode.publishDate)
        descriptionLabel.text = episode.description
        if let imageUrl = episode.imageUrl {
            if !loadingImageIndicator.isAnimating {
                loadingImageIndicator.startAnimating()
            }
            
            timer?.invalidate()
            timer = Timer(timeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                firstly {
                    EpisodeCell.service.fetchImage(withImageUrl: imageUrl)
                }.done(on: .main, flags: nil) { (image) in
                    if let actualUrl = self.episode.imageUrl, imageUrl == actualUrl {
                        self.episodeImageView.image = image
                    }
                }.ensure(on: .main, flags: nil) {
                    self.loadingImageIndicator.stopAnimating()
                }.catch(on: .main, flags: nil, policy: .allErrors) { (_) in
                }
            }
            timer?.tolerance = 0.2
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    // MARK: - outlets
    @IBOutlet var episodeImageView: UIImageView! {
        didSet {
            self.episodeImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet var publishDateLabel: UILabel!
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    
    // MARK: - override methods
    override func prepareForReuse() {
        episodeImageView.image = nil
    }
}
