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

class EpisodesController: UITableViewController {
    private let cellId = "episodeCell"
    private var storedEpisodes: [Episode] = []
    fileprivate var favoriteButton: FavoriteButtonItem {
        return navigationItem.rightBarButtonItem as! FavoriteButtonItem
    }
    fileprivate var isModelInitialized = false
    // MARK: - dependencies
    var model: EpisodesModel! {
        didSet {
            self.model.subscriber = { [weak self] event in
                self?.updateViewWithModel(withEvent: event)
            }
            navigationItem.title = self.model.podcast.name
        }
    }
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isModelInitialized {
            model.initialize()
            isModelInitialized = true
        }
    }
    // MARK: - interaction handlers
    @objc
    fileprivate func onFavoriteButtonTapped() {
        if !favoriteButton.isFavorite {
            model.addPodcastToFavorites()
        }
    }
    // MARK: - helpers
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func selectRow(at indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        tableView.cellForRow(at: indexPath)!.isSelected = true
    }
    
    fileprivate func updateViewWithModel(withEvent event: EpisodesModel.Event) {
        switch event {
        case .initialized:
            tableView.reloadData()
            storedEpisodes = model.storedEpisodes
            favoriteButton.isFavorite = model.isPodcastFavorite
        case .podcastStatusUpdated:
            favoriteButton.isFavorite = model.isPodcastFavorite
        case .episodeDeleted:
            if let deletedEpisodeIndex = storedEpisodes.firstIndex(where: { !model.storedEpisodes.contains($0) }) {
                let episode = storedEpisodes[deletedEpisodeIndex]
                if let indexCellToUpdate = model.episodes.firstIndex(of: episode) {
                    storedEpisodes = model.storedEpisodes
                    let cell = tableView.cellForRow(at: IndexPath(row: indexCellToUpdate, section: 0)) as! EpisodeCell
                    cell.episodeRecordStatus = EpisodeRecordStatus.none
                }
            }
        case .episodeDownloadingProgressUpdated:
            tableView.visibleCells
                .map { $0 as! EpisodeCell }
                .forEach {
                    if let progress = model.downloadingEpisodes[$0.episode] {
                        $0.episodeRecordStatus = .downloading(progress: progress)
                    }
                }
            break
        case .episodeDownloaded:
            if let downloadedEpisodeIndex = model.storedEpisodes.firstIndex(where: { !storedEpisodes.contains($0) }) {
                let episode = model.storedEpisodes[downloadedEpisodeIndex]
                let indexCellToUpdate = model.episodes.firstIndex(of: episode)
                storedEpisodes = model.storedEpisodes
                guard indexCellToUpdate != nil else { return }
                
                let cell = tableView.cellForRow(at: IndexPath(row: indexCellToUpdate!, section: 0)) as! EpisodeCell
                cell.episodeRecordStatus = .downloaded
            }
        case .episodePicked:
            if let index = model.pickedEpisodeIndex {
                if tableView.visibleCells.isEmpty { return }
                selectRow(at: IndexPath(row: index, section: 0))
            }
        default:
            break
        }
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let episode = model.episodes[indexPath.row]
        cell.episode = episode
        if model.storedEpisodes.contains(episode) {
            cell.episodeRecordStatus = .downloaded
        } else {
            if let progress = model.downloadingEpisodes[episode] {
                cell.episodeRecordStatus = .downloading(progress: progress)
            } else {
                cell.episodeRecordStatus = EpisodeRecordStatus.none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.episodes.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.pickEpisode(episodeIndex: indexPath.row)
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
        return model.episodes.count == 0 ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch (tableView.cellForRow(at: indexPath) as! EpisodeCell).episodeRecordStatus {
        case .downloaded:
            return nil
        default:
            let action = UIContextualAction(style: .normal, title: "Download") { [weak self] (_, _, completionHandler) in
                self?.model.downloadEpisode(episodeIndex: indexPath.row)
                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
    }
}
