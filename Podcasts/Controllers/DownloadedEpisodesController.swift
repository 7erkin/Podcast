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

enum DownloadedEpisodesSection {
    case currentDownloadings
    case downloadedEpisodes
}

final class DownloadedEpisodesDataSource: UITableViewDiffableDataSource<DownloadedEpisodesSection, _EpisodeCellViewModel> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.snapshot().itemIdentifiers(inSection: .currentDownloadings).isEmpty {
            return nil
        } else {
            return section == self.snapshot().indexOfSection(.currentDownloadings) ? "Current downloadings" : ""
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
// how to not update view when view not in window
final class DownloadedEpisodesController: UITableViewController {
    typealias DataSource = DownloadedEpisodesDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<DownloadedEpisodesSection, _EpisodeCellViewModel>
    private var subscriptions: Set<AnyCancellable> = []
    private static let cellId = "cellId"
    var viewModel: DownloadedEpisodesViewModel!
    private var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
    private var episodes: [Episode] = []
    private lazy var dataSource = makeDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DownloadedEpisodesController.cellId)
        tableView.dataSource = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
    
    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { (tableView, indexPath, viewModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DownloadedEpisodesController.cellId,
                for: indexPath
            ) as! EpisodeCell
            cell.viewModel = viewModel
            return cell
        }
    }
    
    private lazy var setupBindings: () -> Void = { [unowned self] in
        executeOnce {
            var snapshot = Snapshot()
            snapshot.appendSections([.currentDownloadings, .downloadedEpisodes])
            self.dataSource.apply(snapshot)
            [
                self.viewModel.$downloadEpisodeViewModels
                    .receive(on: DispatchQueue.main)
                    .sink {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteSections([.currentDownloadings])
                        snapshot.appendSections([.currentDownloadings])
                        snapshot.appendItems($0, toSection: .currentDownloadings)
                        self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
                    },
                self.viewModel.$episodeRecordViewModels
                    .receive(on: DispatchQueue.main)
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.playEpisode(withIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return dataSource.snapshot().indexOfSection(.downloadedEpisodes) == nil ? 0 : 250
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        if indexPath.section == dataSource.snapshot().indexOfSection(.downloadedEpisodes) {
            actions.append(UIContextualAction(style: .destructive, title: "Remove record") { [unowned self] (_, _, completionHandler) in
                
                completionHandler(true)
            })
        } else {
            actions.append(UIContextualAction(style: .normal, title: "Cancel downloading") { [unowned self] (_, _, completionHandler) in
                let viewModel = self.dataSource
                    .snapshot()
                    .itemIdentifiers(inSection: .currentDownloadings)[indexPath.row]
                as! EpisodeCellViewModel
                viewModel.cancelEpisodeDownloading()
                completionHandler(true)
            })
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
}
