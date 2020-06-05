//
//  FavoritePodcastSaving.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum FavoritePodcastSavingEvent {}

protocol FavoritePodcastSaving: FavoritePodcastProviding, Observing where Event == FavoritePodcastSavingEvent {
    func saveAsFavorite(podcast: Podcast)
}
