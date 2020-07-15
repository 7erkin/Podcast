//
//  TrackList.swift
//  Podcasts
//
//  Created by Олег Черных on 15/07/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

// must be thread safe
struct TrackList {
    let sourceIdentifier: String
    private var playingTrackIndex: Int
    private var tracks: [Track]
    init(
        _ trackListIdentifier: String,
        tracks: [Track],
        playingTrackIndex index: Int
    ) {
        sourceIdentifier = trackListIdentifier
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
    
    mutating func getNextTrackToPlay() -> Track? {
        if playingTrackIndex + 1 != tracks.count {
            playingTrackIndex += 1
            return tracks[playingTrackIndex]
        }
        
        return nil
    }
    
    mutating func getPreviousTrackToPlay() -> Track? {
        if playingTrackIndex != 0 {
            playingTrackIndex -= 1
            return tracks[playingTrackIndex]
        }
        
        return nil
    }
    
    mutating func getTrackToPlay(atIndex index: Int) -> Track? {
        if tracks.count > index {
            playingTrackIndex = index
            return tracks[playingTrackIndex]
        }
        
        return nil
    }
    
    mutating func addTrack(atIndex index: Int, newTrack: Track) {
        if playingTrackIndex == index {
            playingTrackIndex += 1
        }
        tracks.insert(newTrack, at: index)
    }
    
    mutating func removeTrack(atIndex index: Int) {
        if playingTrackIndex + 1 == tracks.count {
            playingTrackIndex -= 1
        }
        tracks.remove(at: index)
    }
    
    static func areOfSameSource(_ lhs: TrackList, _ rhs: TrackList) -> Bool {
        return lhs.sourceIdentifier == rhs.sourceIdentifier
    }
}
