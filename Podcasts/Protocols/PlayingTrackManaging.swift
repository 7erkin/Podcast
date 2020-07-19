//
//  PlayerStateManaging.swift
//  Podcasts
//
//  Created by user166334 on 6/11/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import AVKit
import Combine

struct PlayingTrackState: CustomStringConvertible {
    var description: String {
        """
        Playing: \(isPlaying).
        TrackName: \(track?.episode.name ?? "").
        Playback: \(trackPlaybackTime?.roundedSeconds ?? 0).
        Duration: \(trackDuration?.roundedSeconds ?? 0)
        """
    }
    
    var isPlaying: Bool
    var track: Track?
    var trackPlaybackTime: CMTime? = nil
    var trackDuration: CMTime? = nil
    var volume: Float
}

enum PlayingTrackManagerEvent {
    case initial(PlayingTrackState)
    case playerStateUpdated(PlayingTrackState)
}

protocol PlayingTrackManaging: class {
    func setPlaybackTime(_ time: CMTime)
    func fastForward15()
    func rewind15()
    func playPause()
    func setVolume(_ volume: Float)
    func subscribe(
        _ subscriber: @escaping (PlayingTrackManagerEvent) -> Void
    ) -> Subscription
}
