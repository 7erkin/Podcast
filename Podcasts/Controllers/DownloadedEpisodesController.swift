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
        let snapshot = dataSource.snapshot()
        if section == snapshot.indexOfSection(.currentDownloadings) {
            return snapshot.numberOfItems(inSection: .currentDownloadings)
        } else {
            return snapshot.numberOfItems(inSection: .downloadedEpisodes)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == .zero ? "Downloading episodes" : " "
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == dataSource.snapshot().indexOfSection(.downloadedEpisodes) {
            return 250
        }
        return 0
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        return nil
    }
}
