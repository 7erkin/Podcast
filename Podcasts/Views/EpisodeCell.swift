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

enum EpisodeRecordStatus {
    case none
    case downloading(progress: Double)
    case downloaded
}

class EpisodeCell: UITableViewCell {
    static var imageFetcher: ImageFetching! = ServiceLocator.imageFetcher
    
    fileprivate var timer: Timer?
    var episode: Episode! {
        didSet {
            updateViewWithEpisode()
        }
    }
    var episodeRecordStatus: EpisodeRecordStatus! {
        didSet {
            updateViewWithEpisodeRecordStatus()
        }
    }
    
    fileprivate func updateViewWithEpisodeRecordStatus() {
        switch episodeRecordStatus! {
        case .none:
            episodeRecordDownloadIndicator.isHidden = true
            progressLabel.isHidden = true
        case .downloading(let progress):
            episodeRecordDownloadIndicator.isHidden = true
            progressLabel.isHidden = false
            progressLabel.text = "\(Int(100 * progress))%"
        case .downloaded:
            episodeRecordDownloadIndicator.isHidden = false
            progressLabel.isHidden = true
        }
    }
    
    fileprivate func updateViewWithEpisode() {
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
                    EpisodeCell.imageFetcher.fetchImage(withImageUrl: imageUrl)
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
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    @IBOutlet var episodeRecordDownloadIndicator: UIButton! {
        didSet {
            self.episodeRecordDownloadIndicator.isEnabled = false
            self.tintColor = .systemBlue
        }
    }
    
    // MARK: - override methods
    override func prepareForReuse() {
        episodeImageView.image = nil
    }
}
