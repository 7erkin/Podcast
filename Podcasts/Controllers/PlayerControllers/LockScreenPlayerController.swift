//
//  LockScreenPlayerController.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit
import PromiseKit
import MediaPlayer

final class LockScreenPlayerController {
    private var subscriptions: [Subscription] = []
    var player: PlayingTrackManaging! {
        didSet {
            self.player
                .subscribe { [unowned self] in
                    switch $0 {
                    case .initial(let playerState):
                        self.updateViewWithModel(playerState)
                    case .playerStateUpdated(let playerState):
                        self.updateViewWithModel(playerState)
                    }
                }
                .stored(in: &subscriptions)
        }
    }
    
    private func updateViewWithModel(_ playerState: PlayingTrackState) {
        let lockScreenMediaCenter = MPNowPlayingInfoCenter.default()
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = playerState.track?.episode.name
        info[MPMediaItemPropertyArtist] = playerState.track?.episode.author
        lockScreenMediaCenter.nowPlayingInfo = info
        lockScreenMediaCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerState.trackPlaybackTime?.roundedSeconds
        lockScreenMediaCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = playerState.trackDuration?.roundedSeconds
    }
}
