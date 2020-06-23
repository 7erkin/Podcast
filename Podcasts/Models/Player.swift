//
//  Player.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit

final class Player: PlayingTrackManaging, TrackListPlaying {
    // MARK: - private properties
    private var subscriptions: [Subscription] = []
    private var playingTrackManagerSubscribers = Subscribers<PlayingTrackManagerEvent>()
    private var trackListPlayerSubscribers = Subscribers<TrackListPlayerEvent>()
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let item = self.player.currentItem {

            }
        }
        return player
    }()
    // MARK: - Singleton
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch let sessionErr {
            print("Configure AudioSession Error: \(sessionErr)")
            fatalError("UB")
        }
    }
    static let shared = Player()
    // MARK: - PlayingTrackManaging
    func fastForward15() {
        shiftByTime(15)
    }
    
    func rewind15() {
        shiftByTime(-15)
    }
    
    func setPlaybackTime(_ time: CMTime) {
        seekToTime(time)
    }
    
    func setVolumeLevel(_ volumeLevel: Int) {
        
    }
    
    func subscribe(_ subscriber: @escaping (PlayingTrackManagerEvent) -> Void) -> Subscription {
        return playingTrackManagerSubscribers.subscribe(action: subscriber)
    }
    
    func playPause() {

    }
    // MARK: - TrackListPlaying
    func setTrackList(_ trackList: [Track], withPlayingTrackIndex trackIndex: Int) {
            
    }
    
    func playNextTrack() {
        
    }
    
    func playPreviousTrack() {
        
    }
    
    func subscribe(_ subscriber: @escaping (TrackListPlayerEvent) -> Void) -> Subscription {
        trackListPlayerSubscribers.subscribe(action: subscriber)
    }
    // MARK: - helpers
    private func shiftByTime(_ time: Int64) {
        let playbackTime = player.currentTime()
        let shiftTime = CMTime(seconds: Double(time), preferredTimescale: 1)
        let seekTime = CMTimeAdd(playbackTime, shiftTime)
        seekToTime(seekTime)
    }
    
    private func seekToTime(_ seekTime: CMTime) {
        player.currentItem?.seek(to: seekTime, completionHandler: { res in
            if res {
            }
        })
    }
}
