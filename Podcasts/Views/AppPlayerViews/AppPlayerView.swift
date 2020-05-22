//
//  PlayerView.swift
//  Podcasts
//
//  Created by Олег Черных on 06/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import AVKit

protocol PlayerViewDelegate: class {
    func dissmis()
    func enlarge()
}

protocol PlayerManaging: class {
    func fastForward15()
    func rewind15()
    func moveToPlaybackTime(_ playbackTime: CMTime)
    func playPause()
}

class AppPlayerView: UIView {
    private let minimizePlayerViewHeight: CGFloat = 75
    private lazy var minimizePlayerView: MinimizePlayerView = {
        let view = Bundle.main.loadNibNamed(
            "MinimizePlayerView",
            owner: self,
            options: nil
        )!.first as! MinimizePlayerView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: minimizePlayerViewHeight),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        view.alpha = 0
        return view
    }()
    
    private lazy var maximizePlayerView: MaximizePlayerView = {
        let view = Bundle.main.loadNibNamed(
            "MaximizePlayerView",
            owner: self,
            options: nil
        )!.first as! MaximizePlayerView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        return view
    }()
    
    var isDissmised: Bool! {
        didSet {
            if self.isDissmised {
                self.frame = .init(origin: .init(x: 0, y: self.superview!.bounds.height - 2 * minimizePlayerViewHeight + 20), size: self.frame.size)
                self.minimizePlayerView.alpha = 1
                self.maximizePlayerView.alpha = 0
            } else {
                self.frame = self.superview!.safeAreaLayoutGuide.layoutFrame
                self.minimizePlayerView.alpha = 0
                self.maximizePlayerView.alpha = 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        _ = minimizePlayerView
        _ = maximizePlayerView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var episode: Episode? {
        set {
            maximizePlayerView.episode = newValue
            minimizePlayerView.episode = newValue
        }
        get {
            maximizePlayerView.episode
        }
    }
    
    var playerState: PlayerState? {
        set {
            maximizePlayerView.playerState = newValue
            minimizePlayerView.playerState = newValue
        }
        get { maximizePlayerView.playerState }
    }
    
    var delegate: PlayerViewDelegate! {
        didSet {
            maximizePlayerView.delegate = self.delegate
            minimizePlayerView.delegate = self.delegate
        }
    }
    
    var playerManager: PlayerManaging? {
        set {
            maximizePlayerView.playerManager = newValue
            minimizePlayerView.playerManager = newValue
        }
        get { maximizePlayerView.playerManager }
    }
}
