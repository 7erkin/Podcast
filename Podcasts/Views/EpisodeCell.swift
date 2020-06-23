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
    var viewModel: EpisodeCellViewModel! {
        didSet {
            if self.viewModel != nil {
                let imageSize = episodeImageView.frame.size
                loadingImageIndicator.startAnimating()
                [
                    self.viewModel.$publishDate.sink { [unowned self] in
                        self.publishDateLabel.text = $0
                    },
                    self.viewModel.$episodeName.sink { [unowned self] in
                        self.episodeNameLabel.text = $0
                    },
                    self.viewModel.$description.sink { [unowned self] in
                        self.descriptionLabel.text = $0
                    },
                    self.viewModel.$progress
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] in
                            self.progressLabel.text = $0
                        },
                    self.viewModel.$isEpisodeDownloaded
                        .receive(on: DispatchQueue.main)
                        .sink { [unowned self] in self.episodeDownloadedIndicator.isHidden = $0 },
                    self.viewModel.episodeImage
                        .receive(on: DispatchQueue.global(qos: .userInitiated))
                        .map { downsample(imageData: $0, to: imageSize, scale: UITraitCollection.current.displayScale) }
                        .receive(on: DispatchQueue.main)
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: { [unowned self] in
                                self.loadingImageIndicator.stopAnimating()
                                self.episodeImageView.image = $0
                            }
                        )
                ].store(in: &subscriptions)
            }
        }
    }
    // MARK: - outlets
    @IBOutlet private var episodeImageView: UIImageView! {
        didSet {
            self.episodeImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet private var episodeDownloadedIndicator: UIButton! {
        didSet {
            self.episodeDownloadedIndicator.isEnabled = false
        }
    }
    @IBOutlet private var publishDateLabel: UILabel!
    @IBOutlet private var episodeNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var progressLabel: UILabel!
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
