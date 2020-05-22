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
    weak var player: Player! {
        didSet {
            self.player?.subscribe(subscriber: AnyObserver<Player.Event>(self))
        }
    }
    fileprivate weak var lockScreenMediaCenter: MPNowPlayingInfoCenter! = MPNowPlayingInfoCenter.default()
    var imageService: ImageServicing! = ImageService.shared
    
    fileprivate func setupNowPlayingInfo() {
        if let imageUrl = player.playingEpisode.episode.imageUrl {
            firstly {
                imageService.fetchImage(withImageUrl: imageUrl)
            }.done(on: .main, flags: nil) { (image) in
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                    return image
                }
                self.lockScreenMediaCenter.nowPlayingInfo![MPMediaItemPropertyArtwork] = artwork
            }
        } else {
            
        }
        
        var info = [String:Any]()
        info[MPMediaItemPropertyTitle] = player.playingEpisode.episode.name
        info[MPMediaItemPropertyArtist] = player.playingEpisode.episode.author
        lockScreenMediaCenter.nowPlayingInfo = info
    }
    
    fileprivate func setupLockscreenCurrentTime() {
        let center = MPNowPlayingInfoCenter.default()
        center.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.playerState.timePast.roundedSeconds
        center.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = player.playerState.duration.roundedSeconds
    }
}
