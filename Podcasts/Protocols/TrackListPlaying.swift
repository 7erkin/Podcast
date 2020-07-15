//
//  PlayingTrackListManaging.swift
//  Podcasts
//
//  Created by Олег Черных on 09/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

enum TrackListPlayerEvent {
    case initial(TrackList?)
    case playingTrackUpdated(TrackList)
    case trackListUpdated(TrackList)
}

enum TrackListSettingMotivation {
    case setNewTrackList
    case updateCurrentTrackList
}

protocol TrackListPlaying: class {
    func setTrackList(_ trackList: TrackList, reasonOfSetting: TrackListSettingMotivation)
    func playNextTrack()
    func playPreviousTrack()
    func playTrack(atIndex index: Int)
    func subscribe(
        _ subscriber: @escaping (TrackListPlayerEvent) -> Void
    ) -> Subscription
}
