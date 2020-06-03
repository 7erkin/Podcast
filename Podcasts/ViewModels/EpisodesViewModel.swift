//
//  EpisodesViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class EpisodesViewModel {
    var podcastName = ObservedValue<String?>(nil)
    var isPodcastFavorite = ObservedValue<Bool>(false)
    var episodeCellViewModels = ObservedValue<[EpisodeCellViewModel]>([])
    var storedEpisodeIndices = ObservedValue<Set<Int>>([])
    private let model: EpisodesModel
    private var subscription: Subscription!
    init(model: EpisodesModel) {
        self.model = model
        podcastName.value = model.podcast.name
        self.subscription = model.subscribe { [weak self] in self?.updateViewModelWithModel(withEvent: $0) }
    }
    
    func favoriteButtonTapped() {
        if !isPodcastFavorite.value { model.addPodcastToFavorites() }
    }
    
    func pickEpisode(_ index: Int) {
        model.pickEpisode(episodeIndex: index)
    }
    
    func downloadEpisode(_ index: Int) {
        model.downloadEpisode(episodeIndex: index)
    }
    
    func initialize() {
        model.initialize()
    }
    
    private func updateViewModelWithModel(withEvent event: EpisodesModel.Event) {
        switch event {
        case .initialized:
            episodeCellViewModels.value = (0..<model.episodes.count).map { index in
                let cellModel = EpisodeCellModel(model: model, episodeIndex: index)
                return EpisodeCellViewModel(model: cellModel)
            }
            isPodcastFavorite.value = model.isPodcastFavorite
        case .episodePicked:
            break
        case .episodeDownloaded:
            break
        case .podcastStatusUpdated:
            break
        default:
            break
        }
    }
}
