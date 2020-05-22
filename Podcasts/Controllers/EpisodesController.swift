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
import PromiseKit

class FavoriteButtonItem: UIBarButtonItem {
    var isFavorite: Bool! {
        didSet {
            if self.isFavorite {
                self.image = UIImage(named: "heart")!
            } else {
                self.title = "Favorite"
                self.image = nil
            }
        }
    }
}

protocol EpisodesControllerCoordinatorDelegate: class {
    func choose(episode: Episode)
}

class EpisodesController: UITableViewController {
    private let cellId = "episodeCell"
    fileprivate var favoriteButton: FavoriteButtonItem {
        return navigationItem.rightBarButtonItem as! FavoriteButtonItem
    }
    private var podcastStorageSubscription: Subscription!
    // MARK: - dependencies
    // ! sign because of strange init requirements
    weak var coordinator: EpisodesControllerCoordinatorDelegate!
    var episodesModel: EpisodesModel! {
        didSet {
//            podcastStorageSubscription = self.favoritePodcastRepository.subscribe(on: .main) { [weak self] event in
//                self?.notify(withEvent: event)
//            }
        }
    }
//    var episodeRepository: EpisodeRepository! {
//        didSet {
//            episodeRepository.subscribe(subscriber: AnyObserver<EpisodeRepository.Event>(self))
//            navigationItem.title = episodeRepository.podcast.name
//            episodeRepository.downloadEpisodes()
//        }
//    }
    // MARK: - view life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let favoriteButton = FavoriteButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(onFavoriteButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
        favoritePodcastRepository.download()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        podcastStorageSubscription = favoritePodcastRepository.subscribe(on: .main) { [weak self] event in
            self?.notify(withEvent: event)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        podcastStorageSubscription = nil
    }
    // MARK: - interaction handlers
    @objc
    fileprivate func onFavoriteButtonTapped() {
        if favoriteButton.isFavorite { return }
        
        favoritePodcastRepository.save(podcast: episodeRepository.podcast)
    }
    // MARK: - helpers
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func updateFavoriteButtonWithModel() {
        favoriteButton.isFavorite = favoritePodcastRepository.podcasts.contains(episodeRepository.podcast)
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = episodeRepository.episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeRepository.episodesCount
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        episodeRepository.pickEpisode(byIndex: indexPath.row)
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
        return episodeRepository.episodesCount == 0 ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Download") { (_, cell, _) in
            
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .none {
            
        }
    }
    // MARK: - Notifiers

}
