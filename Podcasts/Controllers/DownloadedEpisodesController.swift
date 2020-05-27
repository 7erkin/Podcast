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
            model.subscriber = { [weak self] event in self?.updateViewWithModel(withEvent: event) }
        }
    }
    private var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    private var episodes: [Episode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        model.initialize()
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == .zero ? downloadingEpisodes.count : episodes.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == .zero ? "Downloading episodes" : " "
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        let index = indexPath.row
        if indexPath.section == .zero {
            cell.episode = downloadingEpisodes.keys[index]
        } else {
            cell.episode = episodes[index]
            cell.episodeRecordStatus = EpisodeRecordStatus.none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.pickEpisode(episodeIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch (tableView.cellForRow(at: indexPath) as! EpisodeCell).episodeRecordStatus {
        case .downloading(_):
            let action = UIContextualAction(style: .normal, title: "Cancel") { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }

                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        default:
            let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
                guard let self = self else { return }
                
                let deletedEpisode = self.model.storedEpisodes[indexPath.row]
                self.model.delete(episode: deletedEpisode)
                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
    }
    // MARK: - helpers
    fileprivate func updateViewWithModel(withEvent event: DownloadedEpisodesModel.Event) {
        switch event {
        case .initialized:
            downloadingEpisodes = model.downloadingEpisodes
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
            let index = episodes.firstIndex(where: not <<< nextEpisodes.contains)!
            episodes = nextEpisodes
            tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .right)
            break
        case .episodeStartDownloading:
            let nextDownloadingEpisodes = model.downloadingEpisodes
            let index = nextDownloadingEpisodes.firstIndex(where: { downloadingEpisodes[$0.key] == nil })!
            downloadingEpisodes = nextDownloadingEpisodes
            tableView.performBatchUpdates({
                tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .left)
            }, completion: nil)
        case .episodeDownloaded:
            let nextDownloadingEpisodes = model.downloadingEpisodes
            let nextStoredEpisodes = model.storedEpisodes
            let dIndex = downloadingEpisodes.firstIndex(where: { nextDownloadingEpisodes[$0.key] == nil })!
            let sIndex = nextStoredEpisodes.firstIndex(where: not <<< episodes.contains)!
            episodes = nextStoredEpisodes
            downloadingEpisodes = nextDownloadingEpisodes
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [IndexPath(row: dIndex, section: 0)], with: .right)
                tableView.insertRows(at: [IndexPath(row: sIndex, section: 1)], with: .left)
            }, completion: nil)
            break
        case .episodeDownloadingProgressUpdated:
            let cellsToUpdate = tableView.visibleCells
                .filter { tableView.indexPath(for: $0)?.section == 0 }
                .compactMap { $0 }
                .map { $0 as! EpisodeCell }
            for (episode, progress) in model.downloadingEpisodes {
                if let index = cellsToUpdate.firstIndex(where: { $0.episode == episode }) {
                    cellsToUpdate[index].episodeRecordStatus = .downloading(progress: progress)
                }
            }
        }
    }
}
