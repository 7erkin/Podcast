//
//  FavoritePodcastRemoving.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum FavoritePodcastRemovingEvent {}

protocol FavoritePodcastRemoving: FavoritePodcastProviding, Observing where Event == FavoritePodcastRemovingEvent {
    func removeFromFavorite(podcast: Podcast)
}
