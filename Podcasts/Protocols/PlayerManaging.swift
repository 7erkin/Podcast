//
//  Playermanaging.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit
import PromiseKit

enum PlayerManagingEvent: AppEvent {
    case playerStateUpdated
}

protocol PlayerStateManaging: class {
    func playPause()
    func nextEpisode()
    func previousEpisode()
}

enum EpisodePlaybackTimeManagingEvent {
    case playbackTimeUpdated(playbackTime: CMTime)
}

protocol EpisodePlaybackTimeManaging {
    func fastForward15()
    func rewind15()
    func moveToPlaybackTime(_ playbackTime: CMTime)
}
