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
import Foundation
import CoreImage

enum EpisodeRecordStatus {
    case none
    case downloading(progress: Double)
    case downloaded
}

final class EpisodeCell: UITableViewCell {
    static var imageFetcher: ImageFetching! = ServiceLocator.imageFetcher
    private var timer: Timer?
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
    
    private func updateViewWithEpisodeRecordStatus() {
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
    
    private func updateViewWithEpisode() {
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
            timer = Timer(timeInterval: 1, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                let imageViewSize = self.episodeImageView.frame.size
                let scale = self.traitCollection.displayScale
                firstly { () -> Promise<UIImage> in
                    EpisodeCell.imageFetcher.fetchImage(withImageUrl: imageUrl)
                }.then(on: DispatchQueue.global(qos: .userInitiated), flags: nil) { image -> Promise<UIImage> in
                    let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData()!
                    let image = downsample(imageData: data, to: imageViewSize, scale: scale)
                    return Promise { resolver in resolver.fulfill(image) }
                }.done { image in
                    if let actualUrl = self.episode.imageUrl, imageUrl == actualUrl {
                        UIView.transition(
                            with: self.imageView!,
                            duration: 1.0,
                            options: [.curveEaseOut, .transitionCrossDissolve],
                            animations: { [unowned self] in self.episodeImageView.image = image },
                            completion: nil
                        )
                    }
                }.ensure(on: .main, flags: nil) {
                    self.loadingImageIndicator.stopAnimating()
                }.catch(on: .main, flags: nil, policy: .allErrors) { _ in }
            }
        }
        timer?.tolerance = 0.2
        RunLoop.current.add(timer!, forMode: .common)
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
