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
    let model = EpisodeCellModel(
        episode: episode,
        podcast: podcast,
        recordRepository: ServiceLocator.recordRepository
    )
    return EpisodeCellViewModel(model: model)
}

final class EpisodesViewModel: ObservableObject {
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
        case .initial(let podcast, let episodes, let isPodcastFavorite):
            podcastName = podcast.name
            episodeCellViewModels = episodes.map { createEpisodeCellViewModel(episode: $0, podcast: podcast) }
            self.isPodcastFavorite = isPodcastFavorite
        case .episodesFetched(let podcast, let episodes):
            episodeCellViewModels = episodes.map { createEpisodeCellViewModel(episode: $0, podcast: podcast) }
            break
        case .podcastStatusUpdated(let isPodcastFavorite):
            self.isPodcastFavorite = isPodcastFavorite
        }
    }
}
