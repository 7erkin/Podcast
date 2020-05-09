//
//  PodcastCell.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

class PodcastCell: UITableViewCell {
    @IBOutlet var podcastImageView: UIImageView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var episodeCountLabel: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLabel.text = podcast.name
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.episodeCount ?? 0) Episodes"
            if let url = self.podcast.imageUrl {
                let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                    guard let data = data else { return }
                    
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            self?.podcastImageView.image = image
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
