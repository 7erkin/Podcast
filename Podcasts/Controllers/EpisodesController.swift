//
//  EpisodesControllers.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class EpisodesController: UITableViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, EpisodeCellViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeCellViewModel>
    enum Section {
        case main
    }
    private static let cellId = "episodeCell"
    private var favoriteButton: FavoriteButtonItem {
        return navigationItem.rightBarButtonItem as! FavoriteButtonItem
    }
    private var subscriptions: Set<AnyCancellable> = []
    private lazy var dataSource = makeDataSource()
    // MARK: - dependencies
    var viewModel: EpisodesViewModel!
    // MARK: - view lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupFavoriteButton()
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
    }
    // MARK: - interaction handlers
    @objc
    private func onFavoriteButtonTapped() {
        viewModel.savePodcastAsFavorite()
    }
    // MARK: - helpers
    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { (tableView, indexPath, viewModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: EpisodesController.cellId, for: indexPath) as! EpisodeCell
            cell.viewModel = viewModel
            return cell
        }
    }
    
    private func setupBindings() {
        viewModel.$podcastName
            .sink { [unowned self] in self.navigationItem.title = $0 }
            .store(in: &subscriptions)
        viewModel.$isPodcastFavorite
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in self.favoriteButton.isFavorite = $0 }
            .store(in: &subscriptions)
        viewModel.$episodeCellViewModels
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems($0, toSection: .main)
                self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
            }
            .store(in: &subscriptions)
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: EpisodesController.cellId)
        tableView.tableFooterView = UIView()
        tableView.dataSource = dataSource
    }
    
    private func setupFavoriteButton() {
        let favoriteButton = FavoriteButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(onFavoriteButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
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
        return dataSource.snapshot().numberOfItems == 0 ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        if
            let viewModel = (tableView.cellForRow(at: indexPath) as? EpisodeCell)?.viewModel,
            viewModel.isEpisodeDownloaded == false
        {
            let action = UIContextualAction(style: .normal, title: "Download") { (_, _, completionHandler) in
                viewModel.downloadEpisode()
                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
        
        return nil
    }
}
