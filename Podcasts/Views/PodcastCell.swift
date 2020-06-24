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
    @IBOutlet private var podcastImageView: AsyncImageView! {
        didSet {
            self.podcastImageView.contentMode = .scaleAspectFill
            self.podcastImageView.finishLoadingImage = { [unowned self] in self.loadingImageIndicator.stopAnimating() }
            self.podcastImageView.startLoadingImage = { [unowned self] in self.loadingImageIndicator.startAnimating() }
        }
    }
    @IBOutlet private var trackNameLabel: UILabel!
    @IBOutlet private var artistNameLabel: UILabel!
    @IBOutlet private var episodeCountLabel: UILabel!
    @IBOutlet private var loadingImageIndicator: UIActivityIndicatorView! {
        didSet {
            self.loadingImageIndicator.hidesWhenStopped = true
        }
    }
    var viewModel: PodcastCellViewModel! {
        didSet {
            if self.viewModel != nil {
                loadingImageIndicator.startAnimating()
                trackNameLabel.text = self.viewModel.podcastName
                artistNameLabel.text = self.viewModel.artistName
                episodeCountLabel.text = self.viewModel.episodeCount
                podcastImageView.imageUrl = self.viewModel.podcastImageUrl
            }
        }
    }
    
    override func prepareForReuse() {
        podcastImageView.image = nil
        viewModel = nil
    }
}
