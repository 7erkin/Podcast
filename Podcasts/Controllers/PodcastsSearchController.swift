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

class PodcastsSearchController: UITableViewController, UISearchBarDelegate {
    var podcasts = [Podcast]()
    
    let cellId = "podcastCell"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
    }
    
    // MARK: - Common setup
    fileprivate func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        // temp
        searchBar(searchController.searchBar, textDidChange: "Npr")
    }
    
    fileprivate func setupTableView() {
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        // hack to remove empty rows when no podcast is provided
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func fetchPodcasts(withSearchText searchText: String) {
        APIService.shared.fetchPodcasts(searchText: searchText) { podcasts in
            DispatchQueue.global(qos: .userInitiated).async {
                let modifiedPodcasts = podcasts.compactMap { (podcast) -> Podcast? in
                    guard let _ = podcast.feedUrl else { return nil }
                    
                    var copy = podcast
                    copy.imageUrl = copy.imageUrl == nil ? Bundle.main.url(forResource: "podcast", withExtension: "jpeg") : copy.imageUrl
                    return copy
                }
                DispatchQueue.main.async { [weak self] in
                    self?.podcasts = modifiedPodcasts
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.fetchPodcasts(withSearchText: searchText)
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesVC = EpisodesController()
        let podcast = podcasts[indexPath.row]
        episodesVC.podcast = podcast
        navigationController?.pushViewController(episodesVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PodcastCell
        let podcast = podcasts[indexPath.row]
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
        return podcasts.count == 0 ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
}
