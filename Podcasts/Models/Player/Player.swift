//
//  Player.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit
import PromiseKit

protocol EpisodeListPlayable {
    func applyPlayList(_ playList: EpisodePlayList)
    func currentPlayList() -> EpisodePlayList?
}

enum PlayerEvent: AppEvent {
    case playingEpisodeUpdated
    case playerStateUpdated
}

struct PlayerState {
    var timePast: CMTime
    var duration: CMTime
    var volumeLevel: Int
    var isPlaying: Bool
}

class Player {
    // MARK: - private properties
    fileprivate lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let item = self.player.currentItem {
                self.playerState = PlayerState(
                    timePast: item.currentTime(),
                    duration: item.duration,
                    volumeLevel: 10,
                    isPlaying: self.player.timeControlStatus == .playing
                )
            }
        }
        return player
    }()
    private var subscribers: [UUID:(AppEvent) -> Void] = [:]
    // MARK: - Singleton
    private init() {}
    static let shared = Player()
    // MARK: - observable properties
    private var podcast: Podcast!
    private(set) var playerState: PlayerState! {
        didSet {
            notifyAll(withEvent: PlayerEvent.playerStateUpdated)
        }
    }
    private var playList: EpisodePlayList!
    // MARK: - player api
    // public for Player extension to get access. How to fix it???
    func fastForward15() {
        
        shiftByTime(15)
    }
    
    func rewind15() {
        shiftByTime(-15)
    }
    
    func playPause() {
        if player.timeControlStatus == .playing {
            player.pause()
            playerState.isPlaying = false
        } else {
            player.play()
            playerState.isPlaying = true
        }
    }
    
    func moveToPlaybackTime(_ playbackTime: CMTime) {
        seekToTime(playbackTime)
    }
    
    func pause() {
        playerState.isPlaying = false
    }
    
    func nextEpisode() {
        playList.nextEpisode()
    }
    
    func previousEpisode() {
        playList.previousEpisode()
    }
    
    func hasNextEpisode() -> Bool {
        return playList.hasNextEpisode()
    }
    
    func hasPreviousEpisode() -> Bool {
        return playList.hasPreviousEpisode()
    }
    // MARK: - helpers
    private func shiftByTime(_ time: Int64) {
        let playbackTime = player.currentTime()
        let shiftTime = CMTime(seconds: Double(time), preferredTimescale: 1)
        let seekTime = CMTimeAdd(playbackTime, shiftTime)
        seekToTime(seekTime)
    }
    
    private func seekToTime(_ seekTime: CMTime) {
        player.currentItem?.seek(to: seekTime, completionHandler: { [weak self] (res) in
            if res {
            }
        })
    }
    
    private func notifyAll(withEvent event: AppEvent) {
        subscribers.values.forEach { $0(event) }
    }
}

extension Player: EpisodeListPlayable {
    func applyPlayList(_ playList: EpisodePlayList) {
        self.playList = playList
    }
    
    func currentPlayList() -> EpisodePlayList? {
        return playList
    }
}
