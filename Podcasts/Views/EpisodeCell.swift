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

final class EpisodeCell: UITableViewCell {
    var viewModel: EpisodeCellViewModel! {
        didSet {
            self.viewModel.episodeName.valueChanged = { [unowned self] in self.episodeNameLabel.text = $0 }
            self.viewModel.description.valueChanged = { [unowned self] in self.descriptionLabel.text = $0 }
            self.viewModel.progress.valueChanged = { [unowned self] in self.progressLabel.text = $0 }
            self.viewModel.isLoadingEpisodeImageIndicatorActive.valueChanged = { [unowned self] in
                if $0 {
                    self.loadingImageIndicator.startAnimating()
                } else {
                    self.loadingImageIndicator.stopAnimating()
                }
            }
            self.viewModel.isEpisodeDownloadIndicatorHidden.valueChanged = { [unowned self] in self.episodeDownloadIndicator.isHidden = $0 }
            self.viewModel.episodeImage.valueChanged = { [unowned self] in self.episodeImageView.image = $0 }
            self.viewModel.fetchImage(withSize: episodeImageView.frame.size)
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
    @IBOutlet var episodeDownloadIndicator: UIButton! {
        didSet {
            self.episodeDownloadIndicator.isEnabled = false
            self.tintColor = .systemBlue
        }
    }
    
    // MARK: - override methods
    override func prepareForReuse() {
        super.prepareForReuse()
        episodeImageView.image = nil
    }
}
