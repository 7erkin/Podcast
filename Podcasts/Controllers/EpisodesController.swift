//
//  EpisodesControllers.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class EpisodesController: UITableViewController {
    private let cellId = "episodeCell"
    private var favoriteButton: FavoriteButtonItem {
        return navigationItem.rightBarButtonItem as! FavoriteButtonItem
    }
    // MARK: - dependencies
    var viewModel: EpisodesViewModel!
    // MARK: - view life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let favoriteButton = FavoriteButtonItem(
            title: "",
            style: .plain,
            target: self,
            action: #selector(onFavoriteButtonTapped)
        )
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - interaction handlers
    @objc
    private func onFavoriteButtonTapped() {
        viewModel.favoriteButtonTapped()
    }
    // MARK: - helpers
    private func setupTableView() {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
//    private func selectRow(at indexPath: IndexPath) {
//        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
//        tableView.cellForRow(at: indexPath)!.isSelected = true
//    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.viewModel = viewModel.episodeCellViewModels.value[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.episodeCellViewModels.value.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.pickEpisode(indexPath.row)
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
        return viewModel.episodeCellViewModels.value.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !viewModel.storedEpisodeIndices.value.contains(indexPath.row) {
            let action = UIContextualAction(style: .normal, title: "Download") { [weak self] (_, _, completionHandler) in
                self?.viewModel.downloadEpisode(indexPath.row)
                completionHandler(true)
            }
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
        return nil
    }
}
