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
    fatalError("Not implemented")
}

final class EpisodesViewModel: ObservableObject {
    @Published var podcastName: String?
    @Published var isPodcastFavorite: Bool?
    @Published var episodeCellViewModels: [EpisodeCellViewModel] = []
    private let model: EpisodesModel
    private var podcast: Podcast!
    private var subscriptions: [Subscription] = []
    init(model: EpisodesModel) {
        self.model = model
        self.model
            .subscribe { [weak self] in self?.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func savePodcastAsFavorite() {
        if isPodcastFavorite != nil, isPodcastFavorite == true {
            model.savePodcastAsFavorite()
        }
    }
    
    func playEpisode(withIndex index: Int) {
        model.playEpisode(withIndex: index)
    }
    
    private func updateWithModel(_ event: EpisodesModelEvent) {
        switch event {
        case .initial(let podcast, let episodes, let isPodcastFavorite):
            self.podcast = podcast
            podcastName = podcast.name
            episodeCellViewModels = episodes.map { createEpisodeCellViewModel(episode: $0, podcast: podcast) }
            self.isPodcastFavorite = isPodcastFavorite
        case .episodesFetched(let episodes):
            episodeCellViewModels = episodes.map { createEpisodeCellViewModel(episode: $0, podcast: podcast) }
            break
        case .podcastStatusUpdated(let isPodcastFavorite):
            self.isPodcastFavorite = isPodcastFavorite
        }
    }
}
