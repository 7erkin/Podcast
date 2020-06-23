//
//  FavoritesPodcastViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 17/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class FavoritePodcastsViewModel: ObservableObject {
    @Published var badgeText: String? = "NEW!"
    @Published var favoritePodcastCellViewModels: [FavoritePodcastCellViewModel] = []
    @Published var favoritePodcastsFetching: Bool = true
    private var model: FavoritePodcastsModel
    private var subscriptions: [Subscription] = []
    init(_ model: FavoritePodcastsModel) {
        self.model = model
        model
            .subscribe { [unowned self] in self.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func removePodcastFromFavorites(_ podcast: Podcast) {
        model.removeFromFavorites(podcast: podcast)
    }
    
    func viewBecomeVisible() {
        badgeText = nil
    }
    
    private func updateWithModel(_ event: FavoritePodcastsModelEvent) {
        switch event {
        case .initial(let podcasts, let fetching):
            favoritePodcastsFetching = fetching
            if !fetching {
                favoritePodcastCellViewModels = podcasts.map { FavoritePodcastCellViewModel(podcast: $0) }
            }
        case .favoritePodcastsFetched(let podcasts):
            favoritePodcastCellViewModels = podcasts.map { FavoritePodcastCellViewModel(podcast: $0) }
            favoritePodcastsFetching = false
        case .favoritePodcastsUpdated(let podcasts):
            if isPodcastAdded(podcasts) {
                badgeText = "NEW!"
            }
            favoritePodcastCellViewModels = podcasts.map { FavoritePodcastCellViewModel(podcast: $0) }
            favoritePodcastsFetching = false
        }
    }
    
    private func isPodcastAdded(_ podcasts: [Podcast]) -> Bool {
        return podcasts.count != favoritePodcastCellViewModels.count
    }
}
