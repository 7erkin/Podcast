//
//  PodcastsSearchController.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    typealias DataSource = UITableViewDiffableDataSource<Section, PodcastCellViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PodcastCellViewModel>
    enum Section {
        case main
    }
    private static let cellId = "podcastCell"
    private var subscriptions: Set<AnyCancellable> = []
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var dataSource = makeDataSource()
    // MARK: - dependencies
    var viewModel: PodcastsSearchViewModel!
    // MARK: - view lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: - must be executed once
        setupBindings()
    }
    // MARK: - helpers
    private func makeDataSource() -> DataSource {
        return DataSource(tableView: tableView) { (tableView, indexPath, viewModel) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: PodcastsSearchController.cellId, for: indexPath) as! PodcastCell
            cell.viewModel = viewModel
            return cell
        }
    }
    // MARK: - Setup
    private lazy var setupBindings = { [unowned self] in
        executeOnce {
            self.viewModel.$podcastCellViewModels.sink { [unowned self] in
                var snapshot = Snapshot()
                snapshot.appendSections([.main])
                snapshot.appendItems($0, toSection: .main)
                self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
            }.store(in: &self.subscriptions)
        }
    }()
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PodcastsSearchController.cellId)
        tableView.dataSource = dataSource
        // hack to remove empty rows when no podcast is provided
        tableView.tableFooterView = UIView()
    }
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.findPodcasts(bySearchText: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel.findPodcasts(bySearchText: searchBar.text ?? "")
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a Search Term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.snapshot().numberOfItems == 0 && !searchController.hasSearchText ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let podcast = dataSource.itemIdentifier(for: indexPath)?.podcast {
            let model = EpisodesModel(
                podcast: podcast,
                podcastStorage: ServiceLocator.favoritePodcastsStorage,
                episodeFetcher: ServiceLocator.podcastService,
                trackListPlayer: Player.shared
            )
            let viewModel = EpisodesViewModel(model: model)
            let controller = EpisodesController()
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
