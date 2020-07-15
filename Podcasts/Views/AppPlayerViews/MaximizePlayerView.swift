//
//  MaximizePlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 10/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import AVKit
import PromiseKit

final class MaximizePlayerView: UIView {
    // MARK: - constants
    private let undefinedDurationPlaceholder = "--:--:--"
    private let timeSliderDefaultMinValue: Float = 0
    private let timeSliderDefaultMaxValue: Float = 1
    //MARK: - outlets
    @IBOutlet var timeSlider: UISlider! {
        didSet {
            self.timeSlider.isContinuous = false
            self.timeSlider.minimumValue = timeSliderDefaultMinValue
        }
    }
    @IBOutlet var episodeNameLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var episodeDurationLabel: UILabel!
    @IBOutlet var episodePlaybackTimeLabel: UILabel!
    @IBOutlet var episodeImageView: AsyncImageView! {
        didSet {
            self.episodeImageView.layer.cornerRadius = 5
            self.episodeImageView.clipsToBounds = true
            self.episodeImageView.startLoadingImage = {}
            self.episodeImageView.finishLoadingImage = {}
        }
    }
    @IBOutlet var playPauseButton: UIButton!
    //MARK: - action handlers
    @IBAction func onStartMovingTimeSlider(_ sender: Any) {

    }
    @IBAction func onTimeSliderValueChanged(_ sender: Any) {
        let nextPlaybackTime: CMTime = .init(
            seconds: Double((sender as! UISlider).value),
            preferredTimescale: 1
        )
        // playbackTimeBeforeUpdate = playerState.timePast
        isPlaybackSliderUpdateAvailable = false
        expectedPlaybackTime = nextPlaybackTime
        playerManager.moveToPlaybackTime(nextPlaybackTime)
    }
    
    @IBAction func onDismissButtonTapped(_ sender: Any) {
        delegate.dissmis()
    }
    
    @IBAction func onFastForward15ButtonTapped(_ sender: Any) {
        playerManager.fastForward15()
    }
    
    @IBAction func onRewind15ButtonTapped(_ sender: Any) {
        playerManager.rewind15()
    }
    
    @IBAction func onPlayPauseButtonTapped(_ sender: Any) {
        playerManager.playPause()
    }
    
    @objc
    private func onSwipe() {
        delegate.dissmis()
    }
    
    // MARK: - dependencies
    weak var delegate: PlayerViewDelegate!
    weak var playerManager: PlayerManaging!
    // MARK: - constants
    private let shrinkTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    private let playImage: UIImage = UIImage(named: "play")!
    private let pauseImage: UIImage = UIImage(named: "pause")!
    // MARK: - internal dependencies
    // MARK: - for playback slider doesn't debounce after playback time manually update
    private var playbackTimeBeforeUpdate: CMTime?
    private var isPlaybackSliderUpdateAvailable: Bool = true
    private var expectedPlaybackTime: CMTime?
    // MARK: -
    var playerState: PlayerState! { didSet { updateViewWithPlayerState() } }
    // MARK: - override methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDissmisGesture()
        setupInitialViewState()
    }
    
    // MARK: - setup functions
    private func setupDissmisGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(onSwipe))
        swipeGesture.direction = .down
        addGestureRecognizer(swipeGesture)
    }
    
    private func setupInitialViewState() {
        episodeDurationLabel.text = undefinedDurationPlaceholder
        timeSlider.maximumValue = timeSliderDefaultMaxValue
        timeSlider.value = timeSliderDefaultMinValue
        playPauseButton.setImage(playImage, for: .normal)
        episodeImageView.transform = shrinkTransform
    }
    
    // MARK: - update view functions
    private func updateViewWithPlayerState() {
        if let track = playerState.track {
            if episodeImageView.imageUrl != track.episode.imageUrl {
                episodeImageView.imageUrl = track.episode.imageUrl
            }
            // update play/pause button
            var playPauseButtonImage: UIImage!
            if playerState.isPlaying {
                playPauseButtonImage = pauseImage
                if isEpisodeImageViewShrinked() {
                    performEpisodeImageViewAnimatedEnlarge()
                }
            } else {
                playPauseButtonImage = playImage
                if !isEpisodeImageViewShrinked() {
                    performEpisodeImageViewAnimatedShrink()
                }
            }
            playPauseButton.setImage(playPauseButtonImage, for: .normal)
            // update playback time label
            episodePlaybackTimeLabel.text = playerState.trackPlaybackTime?.toPlayerTimePresentation
            // update duration label and slider
            if let duration = playerState.trackDuration {
                episodeDurationLabel.text = duration.convertable ? duration.toPlayerTimePresentation : undefinedDurationPlaceholder
                // timeSlider.maximumValue = Float(duration.roundedSeconds)
            } else {
                episodeDurationLabel.text = undefinedDurationPlaceholder
            }
        }
    }
    
    // MARK: - perform animations functions
    private func performEpisodeImageViewAnimatedShrink() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                self?.episodeImageView.transform = self?.shrinkTransform ?? .identity
            },
            completion: nil
        )
    }
    
    private func performEpisodeImageViewAnimatedEnlarge() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.episodeImageView.transform = .identity
            },
            completion: nil
        )
    }
    
    // MARK: - helpers
    private func isEpisodeImageViewShrinked() -> Bool {
        return episodeImageView.transform == shrinkTransform
    }
    
    private func blurEpisodeImage() {
        let image = episodeImageView.image!
        firstly {
            UIImage.blurImage(image, blurAmount: 20)
        }.done(on: .main, flags: nil) { (bluredImage) in
            if self.episodeImageView.image == image {
                self.episodeImageView.image = bluredImage
            }
        }.catch(on: .main, flags: nil, policy: .allErrors) { _ in
          
        }
    }
    
    private func updateEpisodeImageWithDefaultImage() {
        episodeImageView.image = UIImage(named: "appicon")!
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
