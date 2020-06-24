//
//  FavoritePodcastCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 17/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class FavoritePodcastCellViewModel: Hashable {
    var artistName: String?
    var podcastName: String?
    var podcastImageUrl: URL?
    private var subscriptions: Set<AnyCancellable> = []
    let podcast: Podcast
    init(podcast: Podcast) {
        self.podcast = podcast
        artistName = podcast.artistName
        podcastName = podcast.name
        podcastImageUrl = podcast.imageUrl
    }
    // MARK: - Hashable
    static func == (lhs: FavoritePodcastCellViewModel, rhs: FavoritePodcastCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(artistName)
        hasher.combine(podcastName)
    }
}
