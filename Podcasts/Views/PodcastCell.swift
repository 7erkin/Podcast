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
import Combine

final class PodcastCell: UITableViewCell {
    @IBOutlet private var podcastImageView: UIImageView!
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var episodeCountLabel: UILabel!
    @IBOutlet private var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    private var subscriptions: Set<AnyCancellable> = []
    var viewModel: PodcastCellViewModel! {
        didSet {
            if self.viewModel != nil {
                loadingImageIndicator.startAnimating()
                trackNameLabel.text = self.viewModel.podcastName
                artistNameLabel.text = self.viewModel.artistName
                episodeCountLabel.text = self.viewModel.episodeCount
                let imageSize = podcastImageView.frame.size
                self.viewModel.podcastImagePublisher
                    .receive(on: DispatchQueue.global(qos: .userInitiated))
                    .map { downsample(imageData: $0, to: imageSize, scale: UITraitCollection.current.displayScale) }
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { [weak self] in
                            self?.podcastImageView.image = $0
                            self?.loadingImageIndicator.stopAnimating()
                        }
                    )
                    .store(in: &subscriptions)
            }
        }
    }
    
    override func prepareForReuse() {
        podcastImageView.image = nil
        subscriptions.forEach { $0.cancel() }
        subscriptions = []
        viewModel = nil
    }
}
