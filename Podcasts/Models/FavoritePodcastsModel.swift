//
//  FavoritePodcastsModel.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

enum FavoritePodcastsModelEvent {
    case initial([Podcast], Bool)
    case favoritePodcastsFetched([Podcast])
    case favoritePodcastsUpdated([Podcast])
}

final class FavoritePodcastsModel {
    private var podcasts: [Podcast] = []
    private var fetching: Bool = true
    private let storage: FavoritePodcastsStoraging
    init(favoritePodcastsStorage: FavoritePodcastsStoraging) {
        storage = favoritePodcastsStorage
        storage
            .subscribe { [unowned self] in self.updateWithFavoritePodcastsStorage($0) }
            .stored(in: &subscriptions)
    }
    
    func removeFromFavorites(podcast: Podcast) {
        storage.removeFromFavorites(podcast: podcast)
    }
    // MARK: - subscriptions
    private var subscriptions: [Subscription] = []
    
    private func updateWithFavoritePodcastsStorage(_ event: FavoritePodcastsStorageEvent) {
        switch event {
        case .initial(let podcasts):
            self.podcasts = podcasts
            fetching = false
            subscribers.fire(.favoritePodcastsFetched(podcasts))
        case .removed(_, let podcasts):
            fetching = false
            self.podcasts = podcasts
            subscribers.fire(.favoritePodcastsUpdated(podcasts))
        case .saved(_, let podcasts):
            fetching = false
            self.podcasts = podcasts
            subscribers.fire(.favoritePodcastsUpdated(podcasts))
        }
    }
    // MARK: - subscribers
    private var subscribers = Subscribers<FavoritePodcastsModelEvent>()
    func subscribe(
        _ subscriber: @escaping (FavoritePodcastsModelEvent) -> Void
    ) -> Subscription {
        subscriber(.initial(podcasts, fetching))
        return subscribers.subscribe(action: subscriber)
    }
}
