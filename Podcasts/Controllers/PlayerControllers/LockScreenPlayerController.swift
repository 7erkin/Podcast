//
//  LockScreenPlayerController.swift
//  Podcasts
//
//  Created by Олег Черных on 11/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit
import PromiseKit
import MediaPlayer

class LockScreenPlayerController {
    weak var player: (EpisodeListPlayable & PlayerManaging & Observable)! {
        didSet {
            _ = self.player.subscribe { appEvent in
                DispatchQueue.main.async { [weak self] in
                    self?.updateViewWithModel(withAppEvent: appEvent)
                }
            }.done { self.playerSubscription = $0 }
        }
    }
    fileprivate var playerSubscription: Subscription!
    fileprivate weak var lockScreenMediaCenter: MPNowPlayingInfoCenter! = MPNowPlayingInfoCenter.default()
    var imageFetcher: ImageFetching! = ServiceLocator.imageFetcher
    
    fileprivate func updateViewWithModel(withAppEvent appEvent: AppEvent) {
        if let event = appEvent as? EpisodeListPlayableEvent {
            switch event {
            case .playingEpisodeChanged(let playedEpisode):
                updateNowPlayingInfo(withEpisode: playedEpisode.episode)
            }
            return
        }
        
        if let event = appEvent as? PlayerManagingEvent {
            switch event {
            case .playerStateUpdated(let playerState):
                updateLockscreenCurrentTime(withPlayerState: playerState)
            }
        }
    }
    
    fileprivate func updateNowPlayingInfo(withEpisode episode: Episode) {
        if let imageUrl = episode.imageUrl {
            _ = firstly {
                imageFetcher.fetchImage(withImageUrl: imageUrl)
            }.done(on: .main, flags: nil) { (image) in
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                    return image
                }
                self.lockScreenMediaCenter.nowPlayingInfo![MPMediaItemPropertyArtwork] = artwork
            }
        } else {
            
        }
        
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = episode.name
        info[MPMediaItemPropertyArtist] = episode.author
        lockScreenMediaCenter.nowPlayingInfo = info
    }
    
    fileprivate func updateLockscreenCurrentTime(withPlayerState playerState: PlayerState) {
        let center = MPNowPlayingInfoCenter.default()
        center.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerState.timePast.roundedSeconds
        center.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = playerState.duration.roundedSeconds
    }
}
