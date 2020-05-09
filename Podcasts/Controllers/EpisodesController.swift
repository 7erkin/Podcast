//
//  EpisodesControllers.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    let cellId = "episodeCell"
    
    var episodes: [Episode] = []
    
    var podcast: Podcast! {
        didSet {
            navigationItem.title = self.podcast.name
            if let feedUrl = self.podcast.feedUrl {
                APIService.shared.fetchEpisodes(url: feedUrl) { (episodes) in
                    let modifiedEpisodes = episodes.map { episode -> Episode in
                        if let _ = episode.imageUrl { return episode }
                        var copy = episode
                        copy.imageUrl = self.podcast.imageUrl
                        return copy
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.episodes = modifiedEpisodes
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let window = UIApplication.shared.windows.first!
        let episode = episodes[indexPath.row]
        let episodePlayerVC = EpisodePlayerController()
        episodePlayerVC.episode = episode
        // not sure if it is right
        window.rootViewController?.addChild(episodePlayerVC)
        window.addSubview(episodePlayerVC.view)
        episodePlayerVC.view.frame = window.safeAreaLayoutGuide.layoutFrame
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
}
