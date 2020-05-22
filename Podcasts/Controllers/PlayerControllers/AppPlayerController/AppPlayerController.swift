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
    
    weak var player: Player! {
        didSet {
            self.player.subscribe(subscriber: AnyObserver<Player.Event>(self))
        }
    }
    
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
    
    // NOT FIRED!!!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

extension AppPlayerController: Observer {
    typealias AcceptedEvent = Player.Event
    func notify(withEvent event: Player.Event) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch event {
            case .episodeUpdated:
                self.appPlayerView.episode = self.player.playingEpisode.episode
                if self.view.superview == nil {
                    self.presentAnimator.invoke(forAppPlayerView: self.appPlayerView)
                }
            default:
                self.appPlayerView.playerState = self.player.playerState
            }
        }
    }
}
