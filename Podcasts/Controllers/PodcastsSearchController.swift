//
//  PodcastsSearchController.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol PodcastsSearchControllerCoordinatorDelegate: class {
    func choose(podcast: Podcast)
}

final class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    let cellId = "podcastCell"
    // MARK: - dependencies
    weak var coordinator: PodcastsSearchControllerCoordinatorDelegate?
    var podcastsSearchModel: PodcastsSearchModel! {
        didSet {
            self.podcastsSearchModel.subscriber = { [weak self]  _ in
                self?.tableView.reloadData()
            }
        }
    }
    // MARK: -
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    // MARK: - Common setup
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        // hack to remove empty rows when no podcast is provided
        tableView.tableFooterView = UIView()
    }
    
    private func fetchPodcasts(withSearchText searchText: String) {
        podcastsSearchModel.fetchPodcasts(bySearchText: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchPodcasts(withSearchText: searchText)
    }
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let podcast = podcastsSearchModel.podcasts[indexPath.row]
        coordinator?.choose(podcast: podcast)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastsSearchModel.podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcastsSearchModel.podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a Search Term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcastsSearchModel.podcasts.count == 0 ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}
