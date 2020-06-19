//
//  FavoritePodcastProviding.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

enum FavoritePodcastsStorageEvent {
    case initial([Podcast])
    case saved(Podcast, [Podcast])
    case removed(Podcast, [Podcast])
}

protocol FavoritePodcastsStoraging: class {
    func saveAsFavorite(podcast: Podcast)
    func removeFromFavorites(podcast: Podcast)
    func subscribe(
        _ subscriber: @escaping (FavoritePodcastsStorageEvent) -> Void
    ) -> Subscription
}
