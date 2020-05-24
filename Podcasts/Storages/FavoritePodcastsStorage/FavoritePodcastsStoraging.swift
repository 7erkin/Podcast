//
//  FavoritePodcastStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit

enum FavoritePodcastStoragingEvent {
    case podcastSaved
    case podcastDeleted
}

protocol FavoritePodcastsStoraging  {
    func save(podcast: Podcast)
    func getPodcasts() -> Promise<[Podcast]>
    func delete(podcast: Podcast)
    func hasPodcast(_ podcast: Podcast) -> Promise<Bool>
    func subscribe(
        _ subscriber: @escaping (FavoritePodcastStoragingEvent) -> Void
    ) -> Promise<Subscription>
}

