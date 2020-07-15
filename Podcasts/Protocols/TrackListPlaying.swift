//
//  PlayingTrackListManaging.swift
//  Podcasts
//
//  Created by Олег Черных on 09/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

struct Track {
    var episode: Episode
    var podcast: Podcast
    var url: URL
}
// must be thread safe
class TrackList {
    let identifier: String
    private var playingTrackIndex: Int
    private var tracks: [Track]
    init(
        _ trackListIdentifier: String,
        tracks: [Track],
        playingTrackIndex index: Int
    ) {
        identifier = trackListIdentifier
        self.tracks = tracks
        playingTrackIndex = index
    }
    
    var hasNextTrackToPlay: Bool {
        playingTrackIndex + 1 != tracks.count
    }
    
    var hasPreviousTrackToPlay: Bool {
        playingTrackIndex != 0
    }
    
    var currentPlayingTrack: Track { tracks[playingTrackIndex] }
    
    var currentPlayingTrackIndex: Int { playingTrackIndex }
    
    func getNextTrackToPlay() -> Track? {
        if playingTrackIndex + 1 != tracks.count {
            playingTrackIndex += 1
            return tracks[playingTrackIndex]
        }
        
        return nil
    }
    
    func getPreviousTrackToPlay() -> Track? {
        if playingTrackIndex != 0 {
            playingTrackIndex -= 1
            return tracks[playingTrackIndex]
        }
        
        return nil
    }
    
    func addTrack(atIndex index: Int, _ track: Track) {
        if playingTrackIndex == index {
            playingTrackIndex += 1
        }
        
        tracks.insert(track, at: index)
    }
    
    func removeTrack(atIndex index: Int) {
        if playingTrackIndex == index, playingTrackIndex != 0 {
            playingTrackIndex -= 1
        }
        
        tracks.remove(at: index)
    }
}

enum TrackListPlayerEvent {
    case initial(TrackList?)
    case playingTrackUpdated(TrackList)
    case trackListUpdated(TrackList)
}

protocol TrackListPlaying: class {
    func setTrackList(_ trackList: TrackList)
    func playNextTrack()
    func playPreviousTrack()
    func subscribe(
        _ subscriber: @escaping (TrackListPlayerEvent) -> Void
    ) -> Subscription
}
