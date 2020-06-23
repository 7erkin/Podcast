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

final class DownloadedEpisodesController: UITableViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, _EpisodeCellViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, _EpisodeCellViewModel>
    enum Section {
        case currentDownloadings
        case downloadedEpisodes
    }
    private let cellId = "cellId"
    var viewModel: DownloadedEpisodesViewModel! {
        didSet {
        }
    }
    private var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    private var episodes: [Episode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
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
//            cell.episode = downloadingEpisodes.keys[index]
        } else {
//            cell.episode = episodes[index]
//            cell.episodeRecordStatus = EpisodeRecordStatus.none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        switch (tableView.cellForRow(at: indexPath) as! EpisodeCell).episodeRecordStatus {
//        case .downloading(_):
//            let action = UIContextualAction(style: .normal, title: "Cancel") { (_, _, completionHandler) in
//                completionHandler(true)
//            }
//            let configuration = UISwipeActionsConfiguration(actions: [action])
//            return configuration
//        default:
//            let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
//                guard let self = self else { return }
//
//                let deletedEpisode = self.model.storedEpisodes[indexPath.row]
//                self.model.delete(episode: deletedEpisode)
//                completionHandler(true)
//            }
//            let configuration = UISwipeActionsConfiguration(actions: [action])
//            return configuration
//        }
        return nil
    }
}
