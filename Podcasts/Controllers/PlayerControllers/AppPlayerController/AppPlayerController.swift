//
//  EpisodePlayerController.swift
//  Podcasts
//
//  Created by Олег Черных on 07/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class AppPlayerController: UIViewController {
    typealias AnimationInvoker = (UIView) -> Void
    var dissmisAnimator: AppPlayerViewAnimator!
    var enlargeAnimator: AppPlayerViewAnimator!
    var presentAnimator: AppPlayerViewAnimator!
    var appPlayerView: AppPlayerView { return view as! AppPlayerView }
    private var playerSubscription: Subscription!
    private var hasViewBeenPresented = false
    // MARK: - dependencies
    weak var player: Player! {
        didSet {
            playerSubscription = self.player.subscribe { [weak self] event in
                self?.updateWithPlayer(withEvent: event)
            }
        }
    }
    // MARK: - lifecycle methods
    override func loadView() {
        super.loadView()
        let playerView = AppPlayerView()
        playerView.delegate = self
        playerView.playerManager = self
        view = playerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - helpers
    private func updateWithPlayer(withEvent event: PlayerEvent) {
        if !hasViewBeenPresented {
            presentAnimator.invoke(forAppPlayerView: appPlayerView)
            hasViewBeenPresented = true
        }
        switch event {
        case .playerStateUpdated:
            appPlayerView.playerState = player.playerState
            break
        case .playingEpisodeUpdated:
            appPlayerView.episode = player.playingEpisode
            break
        case .playingPodcastUpdated:
            break
        }
    }
}

extension AppPlayerController: PlayerManaging {
    func fastForward15() {
        player.fastForward15()
    }
    
    func rewind15() {
        player.rewind15()
    }
    
    func moveToPlaybackTime(_ playbackTime: CMTime) {
        player.moveToPlaybackTime(playbackTime)
    }
    
    func playPause() {
        player.playPause()
    }
}

extension AppPlayerController: PlayerViewDelegate {
    func dissmis() {
        dissmisAnimator.invoke(forAppPlayerView: appPlayerView)
    }
    
    func enlarge() {
        enlargeAnimator.invoke(forAppPlayerView: appPlayerView)
    }
}
