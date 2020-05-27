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
    fileprivate var playerSubscription: Subscription!
    // MARK: - dependencies
    weak var player: Player! {
        didSet {
            self.playerSubscription = player.subscribe { [weak self] event in
                self?.updateViewWithModel(withEvent: event)
            }
        }
    }
    var imageFetcher: ImageFetching! = ServiceLocator.imageFetcher
    // MARK: - helpers
    fileprivate func updateViewWithModel(withEvent event: PlayerEvent) {
        switch event {
        case .playerStateUpdated:
            updateLockscreenCurrentTime(withPlayerState: player.playerState)
        case .playingEpisodeUpdated:
            updateNowPlayingInfo(withEpisode: player.playingEpisode)
        default:
            break
        }
    }
    
    fileprivate func updateNowPlayingInfo(withEpisode episode: Episode) {
        let lockScreenMediaCenter = MPNowPlayingInfoCenter.default()
        if let imageUrl = episode.imageUrl {
            _ = firstly {
                imageFetcher.fetchImage(withImageUrl: imageUrl)
            }.done(on: .main, flags: nil) { (image) in
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                    return image
                }
                lockScreenMediaCenter.nowPlayingInfo![MPMediaItemPropertyArtwork] = artwork
            }
        } else {
            
        }
        
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = episode.name
        info[MPMediaItemPropertyArtist] = episode.author
        lockScreenMediaCenter.nowPlayingInfo = info
    }
    
    fileprivate func updateLockscreenCurrentTime(withPlayerState playerState: PlayerState) {
        let lockScreenMediaCenter = MPNowPlayingInfoCenter.default()
        lockScreenMediaCenter.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerState.timePast.roundedSeconds
        lockScreenMediaCenter.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = playerState.duration.roundedSeconds
    }
}
