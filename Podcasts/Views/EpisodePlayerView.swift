//
//  EpisodePlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 06/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import AVKit

protocol EpisodePlayerViewDelegate {
    func dissmis()
    func fastForward15()
    func rewind15()
    func moveToPlaybackTime(_ playbackTime: CMTime)
    func playPause()
}

class EpisodePlayerView: UIView {
    //MARK: - outlets
    @IBOutlet var timeSlider: UISlider! {
        didSet {
            self.timeSlider.isContinuous = false
            self.timeSlider.minimumValue = 0
        }
    }
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var episodeDurationLabel: UILabel!
    @IBOutlet var episodeTimePastLabel: UILabel!
    @IBOutlet var episodeImageView: UIImageView! {
        didSet {
            self.episodeImageView.layer.cornerRadius = 5
            self.episodeImageView.clipsToBounds = true
        }
    }
    @IBOutlet var playPauseButton: UIButton!
    
    //MARK: - actions
    @IBAction func onTimeSliderValueChanged(_ sender: Any) {
        let nextPlaybackTime: CMTime = .init(
            seconds: Double((sender as! UISlider).value),
            preferredTimescale: 1
        )
        delegate.moveToPlaybackTime(nextPlaybackTime)
    }
    @IBAction func onDismissButtonTapped(_ sender: Any) {
        delegate.dissmis()
    }
    @IBAction func onFastForward15ButtonTapped(_ sender: Any) {
        delegate.fastForward15()
    }
    @IBAction func onRewind15ButtonTapped(_ sender: Any) {
        delegate.rewind15()
    }
    @IBAction func onPlayPauseButtonTapped(_ sender: Any) {
        delegate.playPause()
    }
    
    // MARK: -
    fileprivate let shrinkTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    fileprivate let playImage: UIImage = UIImage(named: "play")!
    fileprivate let pauseImage: UIImage = UIImage(named: "pause")!
    var delegate: EpisodePlayerViewDelegate!
    
    var episode: Episode! {
        didSet {
            updateViewWithEpisode()
        }
    }
    
    var episodePlayer: EpisodePlayer! {
        didSet {
            updateViewWithPlayerParameters()
        }
    }
    
    // MARK: - update view functions
    fileprivate func updateViewWithEpisode() {
        episodeNameLabel.text = episode.name
        authorLabel.text = episode.author
        if let episodeImageUrl = episode.imageUrl {
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
    
    fileprivate func updateViewWithPlayerParameters() {
        if episodePlayer.duration.convertable {
            episodeDurationLabel.text = episodePlayer.duration.toPlayerTimePresentation
            timeSlider.maximumValue = Float(episodePlayer.duration.roundedSeconds)
            timeSlider.value = Float(episodePlayer.timePast.roundedSeconds)
        } else {
            episodeDurationLabel.text = "--:--:--"
            timeSlider.maximumValue = 1
            timeSlider.value = 0
        }
        
        var playPauseButtonImage: UIImage!
        if episodePlayer.isPlaying {
            playPauseButtonImage = pauseImage
            performEpisodeImageViewAnimatedShrink()
        } else {
            playPauseButtonImage = playImage
            performEpisodeImageViewAnimatedEnlarge()
        }
        playPauseButton.setImage(playPauseButtonImage, for: .normal)
        episodeTimePastLabel.text = episodePlayer.timePast.toPlayerTimePresentation
    }
    
    // MARK: - perform animations functions
    fileprivate func performEpisodeImageViewAnimatedShrink() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                self?.episodeImageView.transform = .identity
            },
            completion: nil
        )
    }
    
    fileprivate func performEpisodeImageViewAnimatedEnlarge() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.episodeImageView.transform = self?.shrinkTransform ?? .identity
            },
            completion: nil
        )
    }
}

fileprivate extension CMTime {
    var toPlayerTimePresentation: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}
