//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Alamofire

class EpisodeCell: UITableViewCell {
    var episode: Episode! {
        didSet {
            episodeNameLabel.text = self.episode.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            publishDateLabel.text = dateFormatter.string(from: self.episode.publishDate)
            descriptionLabel.text = self.episode.description
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageUrl = self.episode.imageUrl {
                    if let data = try? Data.init(contentsOf: imageUrl) {
                        let image = UIImage(data: data)
                        DispatchQueue.main.async { [weak self] in
                            self?.episodeImageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet var episodeImageView: UIImageView! {
        didSet {
            self.episodeImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet var publishDateLabel: UILabel!
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
}
