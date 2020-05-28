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
    case playingPodcastUpdated
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
    private var playerListSubscription: Subscription!
    private var subscribers: [UUID:(PlayerEvent) -> Void] = [:]
    // MARK: - Singleton
    private init() {}
    static let shared = Player()
    // MARK: - data for client
    private var playingPodcast: Podcast! {
        didSet {
            notifyAll(withEvent: PlayerEvent.playingPodcastUpdated)
        }
    }
    private(set) var playerState: PlayerState! {
        didSet {
            notifyAll(withEvent: PlayerEvent.playerStateUpdated)
        }
    }
    private(set) var playingEpisode: Episode! {
        didSet {
            let playerItem = AVPlayerItem(url: self.playingEpisode.fileUrl ?? self.playingEpisode.streamUrl)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            notifyAll(withEvent: PlayerEvent.playingEpisodeUpdated)
        }
    }
    private var playList: EpisodePlayList! {
        didSet {
            playerListSubscription = self.playList.subscribe { [weak self] event in
                self?.updateWithPlayList(withEvent: event)
            }
            let item = self.playList.getPlayingEpisodeItem()
            self.playingEpisode = item.episode
            self.playingPodcast = item.podcast
        }
    }
    // MARK: - player api
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
        playList.pickNextEpisode()
    }
    
    func previousEpisode() {
        playList.pickPreviousEpisode()
    }
    
    func hasNextEpisode() -> Bool {
        return playList.hasNextEpisode()
    }
    
    func hasPreviousEpisode() -> Bool {
        return playList.hasPreviousEpisode()
    }
    
    func subscribe(_ subscriber: @escaping (PlayerEvent) -> Void) -> Subscription {
        let key = UUID.init()
        subscribers[key] = subscriber
        return Subscription { [weak self] in self?.subscribers.removeValue(forKey: key) }
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
    
    private func updateWithPlayList(withEvent event: EpisodePlayListEvent) {
        switch event {
        case .playingEpisodeChanged:
            let item = playList.getPlayingEpisodeItem()
            playingEpisode = item.episode
            if playingPodcast != item.podcast {
                playingPodcast = item.podcast
            }
        default:
            break
        }
    }
    
    private func notifyAll(withEvent event: PlayerEvent) {
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
