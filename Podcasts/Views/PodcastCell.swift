//
//  PodcastCell.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

final class PodcastCell: UITableViewCell {
    @IBOutlet var podcastImageView: UIImageView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var episodeCountLabel: UILabel!
    @IBOutlet var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    
    override func prepareForReuse() {
        podcastImageView.image = nil
    }
    
    static var imageFetcher: ImageFetching = ServiceLocator.imageFetcher
    var timer: Timer?
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.name
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.episodeCount ?? 0) Episodes"
            if let imageUrl = podcast.imageUrl {
                if !loadingImageIndicator.isAnimating {
                    loadingImageIndicator.startAnimating()
                }
                
                timer?.invalidate()
                timer = Timer(timeInterval: 1.0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    
                    firstly {
                        PodcastCell.imageFetcher.fetchImage(withImageUrl: imageUrl)
                    }.done(on: .main, flags: nil) { (image) in
                        if let actualUrl = self.podcast.imageUrl, imageUrl == actualUrl {
                            self.podcastImageView.image = image
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
    }
}
