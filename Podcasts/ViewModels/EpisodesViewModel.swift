//
//  EpisodesViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class EpisodesViewModel {
    @Published
    var podcastName: String?
    var isPodcastFavorite: Bool = false
    var episodeCellViewModels: [EpisodeCellViewModel] = []
    var storedEpisodeIndices: Set<Int> = []
    private let model: EpisodesModel
    private var subscription: Subscription!
    init(model: EpisodesModel) {
        self.model = model
        podcastName.value = model.podcast.name
    }
    
    func favoriteButtonTapped() {
        if !isPodcastFavorite.value { model.addPodcastToFavorites() }
    }
    
    func pickEpisode(_ index: Int) {
        model.pickEpisode(episodeIndex: index)
    }
    
    func downloadEpisode(_ index: Int) {
    }
    
    func initialize() {
        model.initialize()
    }
}
