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

final class AppPlayerController: UIViewController {
    typealias AppPlayerViewAnimator = (AppPlayerView) -> Void
    
    private var appPlayerView: AppPlayerView { return view as! AppPlayerView }
    private var subscriptions: [Subscription] = []
    private var hasAppPlayerViewBeenPresented = false
    // MARK: - dependencies
    var dissmisAnimationInvoker: AppPlayerViewAnimator!
    var enlargeAnimationInvoker: AppPlayerViewAnimator!
    weak var player: PlayingTrackManaging! {
        didSet {
            self.player
                .subscribe { [unowned self] in
                    switch $0 {
                    case .initial(let playerState):
                        self.updateViewWithModel(playerState)
                    case .playerStateUpdated(let playerState):
                        print(playerState)
                        self.updateViewWithModel(playerState)
                    }
                }
                .stored(in: &subscriptions)
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
    private func updateViewWithModel(_ playerState: PlayerState) {
        if !hasAppPlayerViewBeenPresented {
            enlargeAnimationInvoker(appPlayerView)
            hasAppPlayerViewBeenPresented = true
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
        player.setPlaybackTime(playbackTime)
    }
    
    func playPause() {
        player.playPause()
    }
}

extension AppPlayerController: PlayerViewDelegate {
    func dissmis() {
        dissmisAnimationInvoker(appPlayerView)
    }
    
    func enlarge() {
        enlargeAnimationInvoker(appPlayerView)
    }
}
