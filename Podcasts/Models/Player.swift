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
    private lazy var player: AVPlayer = {
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
    // MARK: - player api
    func fastForward15() {
        shiftByTime(15)
    }
    
    func rewind15() {
        shiftByTime(-15)
    }
    
    func playPause() {

    }
    
    func moveToPlaybackTime(_ playbackTime: CMTime) {
        seekToTime(playbackTime)
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
