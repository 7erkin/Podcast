//
//  MinimizePlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 10/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

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
    
    var episode: Episode! {
        didSet {
            episodeNameLabel.text = self.episode.name
            if let episodeImageUrl = self.episode.imageUrl {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    
                    if let data = try? Data(contentsOf: episodeImageUrl) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async { [weak self] in
                                if let actualRequestedImageUrl = self?.episode.imageUrl, actualRequestedImageUrl == episodeImageUrl {
                                    self?.episodeImageView.image = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    var episodePlayer: EpisodePlayer! {
        didSet {
            let image = self.episodePlayer.isPlaying ? pauseImage : playImage
            playPauseButton.setImage(image, for: .normal)
        }
    }
    
    weak var playerManager: PlayerManaging?
    weak var delegate: PlayerViewDelegate?
    weak var playerPresenter: PlayerPresenting?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        addGestureRecognizer(tapGesture)
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        leftSwipeGesture.direction = .left
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        rightSwipeGesture.direction = .right
        addGestureRecognizer(leftSwipeGesture)
        addGestureRecognizer(rightSwipeGesture)
    }
    
    @objc
    fileprivate func onTapped() {
        delegate?.enlarge()
    }
    
    @objc
    fileprivate func onSwipe() {
        playerPresenter?.closePlayer()
    }
}
