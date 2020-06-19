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
    case favoritePodcastsUpdated([Podcast])
}

final class FavoritePodcastsModel {
    private var podcasts: [Podcast] = [] {
        didSet {
            fetching = false
            subscribers.fire(.favoritePodcastsUpdated(self.podcasts))
        }
    }
    private var fetching: Bool = true
    private let storage: FavoritePodcastsStoraging
    init(favoritePodcastsStorage: FavoritePodcastsStoraging) {
        storage = favoritePodcastsStorage
        storage
            .subscribe { [unowned self] in self.updateWithFavoritePodcastsStorage($0) }
            .stored(in: &subscriptions)
    }
    
    func removeFromFavorites(podcastIndex index: Int) {
        storage.removeFromFavorites(podcast: podcasts[index])
    }
    // MARK: - subscriptions
    private var subscriptions: [Subscription] = []
    
    private func updateWithFavoritePodcastsStorage(_ event: FavoritePodcastsStorageEvent) {
        switch event {
        case .initial(let podcasts):
            self.podcasts = podcasts
            break
        case .removed(_, let podcasts):
            self.podcasts = podcasts
            break
        case .saved(_, let podcasts):
            self.podcasts = podcasts
            break
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
