//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Combine
import UIKit
import Foundation
import CoreImage

final class EpisodeCell: UITableViewCell {
    private var subscriptions: Set<AnyCancellable> = []
    var viewModel: EpisodeCellOutput! {
        didSet {
            if self.viewModel != nil {
                [
                    self.viewModel.publishDatePublisher.sink { [unowned self] in
                        self.publishDateLabel.text = $0
                    },
                    self.viewModel.episodeNamePublisher.sink { [unowned self] in
                        self.episodeNameLabel.text = $0
                    },
                    self.viewModel.descriptionPublisher.sink { [unowned self] in
                        self.descriptionLabel.text = $0
                    },
                    self.viewModel.downloadingProgressPublisher
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] in
                            self.progressLabel.text = $0
                        },
                    self.viewModel.isEpisodeDownloadedPublisher
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] in
                            self.episodeDownloadedIndicator.isHidden = $0
                        },
                    self.viewModel.episodeImageUrlPublisher
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] in
                            self.episodeImageView.imageUrl = $0
                        }
                ].store(in: &subscriptions)
            }
        }
    }
    // MARK: - outlets
    @IBOutlet private var episodeImageView: AsyncImageView! {
        didSet {
            self.episodeImageView.contentMode = .scaleAspectFill
            self.episodeImageView.finishLoadingImage = { [unowned self] in self.loadingImageIndicator.stopAnimating() }
            self.episodeImageView.startLoadingImage = { [unowned self] in self.loadingImageIndicator.startAnimating() }
        }
    }
    @IBOutlet private var episodeDownloadedIndicator: UIButton! {
        didSet {
            self.episodeDownloadedIndicator.isEnabled = false
            self.episodeDownloadedIndicator.isHidden = true
        }
    }
    @IBOutlet private var publishDateLabel: UILabel!
    @IBOutlet private var episodeNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var progressLabel: UILabel! { didSet { self.progressLabel.text = nil } }
    @IBOutlet private var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    // MARK: - override methods
    override func prepareForReuse() {
        super.prepareForReuse()
        episodeImageView.image = nil
        subscriptions = []
        viewModel = nil
    }
}
