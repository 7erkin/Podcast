//
//  DownloadedEpisodeRecordsController.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Combine
final class DownloadedEpisodesController: UITableViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, _EpisodeCellViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, _EpisodeCellViewModel>
    enum Section {
        case currentDownloadings
        case downloadedEpisodes
    }
    private var subscriptions: Set<AnyCancellable> = []
    private static let cellId = "cellId"
    var viewModel: DownloadedEpisodesViewModel!
    private var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    private var episodes: [Episode] = []
    private var dataSource: DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DownloadedEpisodesController.cellId)
    }
    
    private lazy var setupBindings: () -> Void = { [unowned self] in
        executeOnce {
            [
                self.viewModel.$downloadingEpisodes
                    .sink {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteSections([.currentDownloadings])
                        snapshot.appendSections([.currentDownloadings])
                        snapshot.appendItems($0, toSection: .currentDownloadings)
                        self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                    },
                self.viewModel.$downloadedEpisodes
                    .sink {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteSections([.downloadedEpisodes])
                        snapshot.appendSections([.downloadedEpisodes])
                        snapshot.appendItems($0, toSection: .downloadedEpisodes)
                        self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                    }
            ].store(in: &self.subscriptions)
        }
    }()
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadedEpisodesController.cellId, for: indexPath) as! EpisodeCell
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
