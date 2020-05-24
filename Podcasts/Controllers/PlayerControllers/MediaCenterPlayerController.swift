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

class MediaCenterPlayerController {
    // playermanager
    weak var player: Player! {
        didSet {
            
        }
    }
    
    fileprivate weak var mediaCenter: MPRemoteCommandCenter? = MPRemoteCommandCenter.shared()
    
    init() {
        setup()
    }
    
    fileprivate func setup() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let playPauseHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.playPause()
            return .success
        }
        let playPreviousEpisodeHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.previousEpisode()
            return .success
        }
        let playNextEpisodeHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.player.nextEpisode()
            return .success
        }
        
        // playButton
        mediaCenter?.playCommand.isEnabled = true
        mediaCenter?.playCommand.addTarget(handler: playPauseHandler)
        // pauseButton
        mediaCenter?.pauseCommand.isEnabled = true
        mediaCenter?.pauseCommand.addTarget(handler: playPauseHandler)
        // toggleButton
        mediaCenter?.togglePlayPauseCommand.isEnabled = true
        mediaCenter?.togglePlayPauseCommand.addTarget(handler: playPauseHandler)
        // playPreviousEpisodeButton
        mediaCenter?.previousTrackCommand.addTarget(handler: playPreviousEpisodeHandler)
        // playNextEpisodeHandler
        mediaCenter?.nextTrackCommand.addTarget(handler: playNextEpisodeHandler)
    }
    
    fileprivate func updateViewWithModel() {
        mediaCenter?.nextTrackCommand.isEnabled = player.hasNextEpisode()
        mediaCenter?.previousTrackCommand.isEnabled = player.hasPreviousEpisode()
    }
}
