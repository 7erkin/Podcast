//
//  MinimizePlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 10/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

final class MinimizePlayerView: UIStackView {
    @IBOutlet var episodeImageView: AsyncImageView! {
        didSet {
            self.episodeImageView.image = UIImage(named: "appicon")
        }
    }
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    
    @IBAction func onPlayPauseButtonTapped(_ sender: Any) {
        playerManager?.playPause()
    }
    @IBAction func onFastForward15ButtonTapped(_ sender: Any) {
        playerManager?.fastForward15()
    }
    
    private let playImage: UIImage = UIImage(named: "play")!
    private let pauseImage: UIImage = UIImage(named: "pause")!
    
    var playerState: PlayingTrackState! {
        didSet {
            let image = self.playerState.isPlaying ? pauseImage : playImage
            playPauseButton.setImage(image, for: .normal)
            episodeNameLabel.text = self.playerState.track?.episode.name
            if let nextImageUrl = self.playerState.track?.episode.imageUrl {
                if episodeImageView.imageUrl != nextImageUrl {
                    blurEpisodeImageView()
                    episodeImageView.imageUrl = nextImageUrl
                }
            }
        }
    }
    
    weak var playerManager: PlayerManaging?
    weak var delegate: PlayerViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onTapped() {
        delegate?.enlarge()
    }
    
    private func blurEpisodeImageView() {
        if let image = episodeImageView.image, let ciImage = CIImage(image: image) {
            let blurFilter = CIFilter(name: "CIGaussianBlur")
            blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
            blurFilter?.setValue(1.0, forKey: kCIInputRadiusKey)
            
            guard let outputImage = blurFilter?.outputImage else { return }
            
            episodeImageView.image = UIImage(ciImage: outputImage)
        }
    }
}
