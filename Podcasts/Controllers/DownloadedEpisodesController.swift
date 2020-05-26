//
//  DownloadedEpisodeRecordsController.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

class DownloadedEpisodesController: UITableViewController {
    fileprivate let cellId = "cellId"
    var model: DownloadedEpisodesModel! {
        didSet {
            self.model.subscriber = { [weak self] event in self?.updateViewWithModel(withEvent: event) }
        }
    }
    private var downloadingEpisodes: [Episode] = []
    private var episodes: [Episode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        model.initialize()
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? downloadingEpisodes.count : episodes.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Downloading" : "Downloaded episodes"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = episodes[indexPath.row]
        cell.episodeRecordStatus = EpisodeRecordStatus.none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.pickEpisode(episodeIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            let deletedEpisode = self.model.storedEpisodes[indexPath.row]
            self.model.delete(episode: deletedEpisode)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    // MARK: - helpers
    fileprivate func updateViewWithModel(withEvent event: DownloadedEpisodesModel.Event) {
        switch event {
        case .initialized:
            downloadingEpisodes = model.downloadingEpisodes.map { $0.key }
            episodes = model.storedEpisodes
            tableView.reloadData()
            break
        case .episodePicked:
            if let index = model.pickedEpisodeIndex {
                let cell = tableView.cellForRow(at: index.toIndexPath)
                cell?.isHighlighted = true
            }
            break
        case .episodeDeleted:
            let nextEpisodes = model.storedEpisodes
            let index = episodes.firstIndex(where: { not(nextEpisodes.contains($0)) })!
            episodes = nextEpisodes
            tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .right)
            break
        case .episodeStartDownloading:
            print("Start downloading")
            let nextDownloadingEpisodes = model.downloadingEpisodes
            let index = nextDownloadingEpisodes.firstIndex(where: { not(downloadingEpisodes.contains($0.key)) })!
            downloadingEpisodes = nextDownloadingEpisodes.map { $0.key }
            tableView.performBatchUpdates({
                tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .left)
            }, completion: nil)
        case .episodeDownloaded:
            let nextDownloadingEpisodes = model.downloadingEpisodes.map { $0.key }
            let nextStoredEpisodes = model.storedEpisodes
            let dIndex = downloadingEpisodes.firstIndex(where: { not(nextDownloadingEpisodes.contains($0)) })!
            let sIndex = nextStoredEpisodes.firstIndex(where: { not(episodes.contains($0)) })!
            episodes = nextStoredEpisodes
            downloadingEpisodes = nextDownloadingEpisodes
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: dIndex, section: 0)], with: .right)
                tableView.insertRows(at: [IndexPath(row: sIndex, section: 1)], with: .left)
            }, completion: nil)
            break
        case .episodeDownloadingProgressUpdated:
            
            break
        }
    }
}
