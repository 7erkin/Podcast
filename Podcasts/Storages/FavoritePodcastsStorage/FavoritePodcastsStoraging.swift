//
//  FavoritePodcastStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit

protocol FavoritePodcastsStoraging  {
    func save(podcast: Podcast)
    func getFavoritePodcasts() -> Promise<[Podcast]>
    func delete(podcast: Podcast)
}

