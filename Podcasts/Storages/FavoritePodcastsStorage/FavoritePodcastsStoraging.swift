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
    case podcastsLoaded
}

protocol FavoritePodcastsStoraging  {
    func save(podcast: Podcast)
    func getPodcasts() -> Promise<[Podcast]>
    func delete(podcast: Podcast)
    func load()
}

