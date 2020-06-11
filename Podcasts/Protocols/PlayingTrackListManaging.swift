//
//  PlayingTrackListManaging.swift
//  Podcasts
//
//  Created by Олег Черных on 09/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

struct Track {
    var episode: Episode
    var podcast: Podcast
    var url: URL
}

protocol PlayingTrackListManaging: class {
    var playingTrack: Track { get }
    var trackList: [Track] { get set }
    func playNextTrack()
    func playPreviousTrack()
    func hasNextTrack() -> Bool
    func hasPreviousTrack() -> Bool
}
