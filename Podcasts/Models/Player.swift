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
    private let playingTrackManagerSubscribers = Subscribers<PlayingTrackManagerEvent>()
    private let trackListPlayerSubscribers = Subscribers<TrackListPlayerEvent>()
    private lazy var player: AVPlayer = { [weak self] in
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        let updatePlayerState: (CMTime) -> Void = { _ in
            if let item = self?.player.currentItem, var playerState = self?.playerState {
                if let isPlayerPausedByClient = self?.isPlayerPausedByClient, !isPlayerPausedByClient {
                    playerState.trackPlaybackTime = item.currentTime()
                    playerState.trackDuration = item.duration
                    playerState.isPlaying = true
                    self?.playerState = playerState
                }
            }
        }
        player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: DispatchQueue.main,
            using: updatePlayerState
        )
        return player
    }()
    private var playerState: PlayerState {
        didSet {
            playingTrackManagerSubscribers.fire(.playerStateUpdated(self.playerState))
        }
    }
    /* internal part of invariant for not to update playerState
    in "player.addPeriodicTimeObserver" func
    when player has been asked to pause */
    private var isPlayerPausedByClient = false
    private var trackList: TrackList?
    // MARK: - Singleton
    private init() {
        playerState = PlayerState(isPlaying: false, volumeLevel: 2)
        configureAudioSession()
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
        player.volume = 2
    }
    
    func subscribe(_ subscriber: @escaping (PlayingTrackManagerEvent) -> Void) -> Subscription {
        return playingTrackManagerSubscribers.subscribe(action: subscriber)
    }
    
    func playPause() {
        if playerState.isPlaying {
            player.pause()
            isPlayerPausedByClient = true
            playerState.isPlaying = false
        } else {
            isPlayerPausedByClient = false
            player.play()
        }
    }
    // MARK: - TrackListPlaying
    func setTrackList(_ trackList: TrackList) {
        self.trackList = trackList
        trackListPlayerSubscribers.fire(.trackListUpdated(trackList))
        play(trackList.currentPlayingTrack)
    }
    
    func playNextTrack() {
        guard let trackList = trackList else { return }
        
        if let track = trackList.getNextTrackToPlay() {
            trackListPlayerSubscribers.fire(.playingTrackUpdated(trackList))
            play(track)
        }
    }
    
    func playPreviousTrack() {
        guard let trackList = trackList else { return }
        
        if let track = trackList.getPreviousTrackToPlay() {
            trackListPlayerSubscribers.fire(.playingTrackUpdated(trackList))
            play(track)
        }
    }
    
    func subscribe(_ subscriber: @escaping (TrackListPlayerEvent) -> Void) -> Subscription {
        trackListPlayerSubscribers.subscribe(action: subscriber)
    }
    // MARK: - helpers
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch let sessionErr {
            print("Configure AudioSession Error: \(sessionErr)")
            fatalError("UB")
        }
    }
    
    private func play(_ track: Track) {
        let playerItem = AVPlayerItem(url: track.url)
        player.replaceCurrentItem(with: playerItem)
        playerState = PlayerState(isPlaying: false, track: track, volumeLevel: 2)
        isPlayerPausedByClient = false
        player.play()
    }
    
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
