//
//  PlayerStateManaging.swift
//  Podcasts
//
//  Created by user166334 on 6/11/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import AVKit

struct PlayerState {
    var isPlaying: Bool
    var track: Track
    var trackPlaybackTime: CMTime
    var trackDuration: CMTime
    var volumeLevel: Int
}

enum PlayingTrackManagerEvent {
    case initial(PlayerState)
    case playerStateUpdated(PlayerState)
}

protocol PlayingTrackManaging: class {
    func setPlaybackTime(_ time: CMTime)
    func fastForward15()
    func rewind15()
    func playPause()
    func setVolumeLevel(_ volumeLevel: Int)
    func subscribe(
        _ subscriber: @escaping (PlayingTrackManagerEvent) -> Void
    ) -> Subscription
}
