//
//  FavoritePodcastProviding.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

enum FavoritePodcastStorageEvent {
    case initial([Podcast])
    case saved(Podcast, [Podcast])
    case removed(Podcast, [Podcast])
}

protocol FavoritePodcastStoraging: class {
    func saveAsFavorite(podcast: Podcast)
    func removeFromFavorite(podcast: Podcast)
    func subscribe(
        _ subscriber: @escaping (FavoritePodcastStorageEvent) -> Void
    ) -> Subscription
}
