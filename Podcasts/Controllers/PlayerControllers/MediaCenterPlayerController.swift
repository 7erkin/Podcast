//
//  MediaCenterPlayerController.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import AVKit
import MediaPlayer

final class MediaCenterPlayerController {
    private var subscriptions: [Subscription] = []
    // MARK: - dependency
    weak var player: (TrackListPlaying & PlayingTrackManaging)! {
        didSet {
            self.player
                .subscribe { [weak self] in self?.updateViewWithTrackListPlayer($0) }
                .stored(in: &subscriptions)
        }
    }
    // MARK: -
    init() {
        setup()
    }
    // MARK: - helpers
    private func setup() {
        let mediaCenter = MPRemoteCommandCenter.shared()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let playPauseHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.playPause()
            return .success
        }
        let playPreviousEpisodeHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.playPreviousTrack()
            return .success
        }
        let playNextEpisodeHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.playNextTrack()
            return .success
        }
        
        // playButton
        mediaCenter.playCommand.isEnabled = true
        mediaCenter.playCommand.addTarget(handler: playPauseHandler)
        // pauseButton
        mediaCenter.pauseCommand.isEnabled = true
        mediaCenter.pauseCommand.addTarget(handler: playPauseHandler)
        // toggleButton
        mediaCenter.togglePlayPauseCommand.isEnabled = true
        mediaCenter.togglePlayPauseCommand.addTarget(handler: playPauseHandler)
        // playPreviousEpisodeButton
        mediaCenter.previousTrackCommand.addTarget(handler: playPreviousEpisodeHandler)
        // playNextEpisodeHandler
        mediaCenter.nextTrackCommand.addTarget(handler: playNextEpisodeHandler)
    }
    
    private func updateViewWithTrackListPlayer(_ event: TrackListPlayerEvent) {
        let update: ([Track], Int) -> Void = {
            let mediaCenter = MPRemoteCommandCenter.shared()
            mediaCenter.nextTrackCommand.isEnabled = $0.count != $1 + 1
            mediaCenter.previousTrackCommand.isEnabled = $1 != 0
        }
        
        switch event {
        case .initial(let trackList, let playingTrackIndex):
            update(trackList, playingTrackIndex)
        case .playingTrackUpdated(let trackList, let playingTrackIndex):
            update(trackList, playingTrackIndex)
        case .trackListUpdated(let trackList, let playingTrackIndex):
            update(trackList, playingTrackIndex)
        }
    }
}
