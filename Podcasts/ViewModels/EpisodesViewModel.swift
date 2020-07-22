//
//  EpisodesViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

func createEpisodeCellViewModel(episode: Episode, podcast: Podcast) -> EpisodeCellViewModel {
    let model = EpisodeModel(
        episode: episode,
        podcast: podcast,
        recordRepository: ServiceLocator.recordRepository
    )
    return EpisodeCellViewModel(model: model)
}

final class EpisodesViewModel {
    @Published private(set) var podcastName: String?
    @Published private(set) var isPodcastFavorite: Bool?
    @Published private(set) var episodeCellViewModels: [EpisodeCellViewModel] = []
    
    private let model: EpisodesModel
    private var subscriptions: [Subscription] = []
    init(model: EpisodesModel) {
        self.model = model
        self.model
            .subscribe { [weak self] in self?.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func savePodcastAsFavorite() {
        if isPodcastFavorite != nil, isPodcastFavorite == false {
            model.savePodcastAsFavorite()
        }
    }
    
    func playEpisode(withIndex index: Int) {
        model.playEpisode(withIndex: index)
    }
    
    private func updateWithModel(_ event: EpisodesModelEvent) {
        switch event {
        case .initial(let state):
            podcastName = state.podcast.name
            episodeCellViewModels = state.episodes.map { createEpisodeCellViewModel(episode: $0, podcast: state.podcast) }
            self.isPodcastFavorite = state.isPodcastFavorite ?? false
        case .episodesFetched(let state):
            episodeCellViewModels = state.episodes.map { createEpisodeCellViewModel(episode: $0, podcast: state.podcast) }
            break
        case .podcastStatusUpdated(let state):
            self.isPodcastFavorite = state.isPodcastFavorite ?? false
        default:
            break
        }
    }
}
