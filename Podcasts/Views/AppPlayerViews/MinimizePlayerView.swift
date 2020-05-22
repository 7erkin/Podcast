//
//  MinimizePlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 10/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

class MinimizePlayerView: UIStackView {
    @IBOutlet var episodeImageView: UIImageView!
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    
    @IBAction func onPlayPauseButtonTapped(_ sender: Any) {
        playerManager?.playPause()
    }
    @IBAction func onFastForward15ButtonTapped(_ sender: Any) {
        playerManager?.fastForward15()
    }
    
    fileprivate let playImage: UIImage = UIImage(named: "play")!
    fileprivate let pauseImage: UIImage = UIImage(named: "pause")!
    
    var imageService: ImageServicing! = ImageService.shared
    
    var episode: Episode! {
        didSet {
            episodeNameLabel.text = self.episode.name
            if let _ = episodeImageView.image {
                blurEpisodeImageView()
            }
            
            if let episodeImageUrl = self.episode.imageUrl {
                firstly {
                    imageService.fetchImage(withImageUrl: episodeImageUrl)
                }.done(on: .main, flags: nil) { (image) in
                    if episodeImageUrl == self.episode.imageUrl {
                        self.episodeImageView.image = image
                    }
                }.ensure(on: .main, flags: nil) {
                    // hide loading indicator on episode image
                }.catch({ (_) in
                    // inform user with error
                })
            }
        }
    }
    
    var playerState: Player.PlayerState! {
        didSet {
            let image = self.playerState.isPlaying ? pauseImage : playImage
            playPauseButton.setImage(image, for: .normal)
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
    fileprivate func onTapped() {
        delegate?.enlarge()
    }
    
    fileprivate func blurEpisodeImageView() {
        guard let ciImage = CIImage(image: episodeImageView.image!) else { return }
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(20.0, forKey: kCIInputRadiusKey)
        
        guard let outputImage = blurFilter?.outputImage else { return }
        
        episodeImageView.image = UIImage(ciImage: outputImage)
    }
}
