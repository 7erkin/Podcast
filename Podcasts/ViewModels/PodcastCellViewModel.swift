//
//  PodcastCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 20/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class PodcastCellViewModel {
    private(set) var podcastName: String?
    private(set) var artistName: String?
    private(set) var episodeCount: String?
    private(set) var podcastImageUrl: URL?
    let podcast: Podcast
    init(podcast: Podcast) {
        self.podcast = podcast
        podcastImageUrl = podcast.imageUrl
        podcastName = podcast.name
        artistName = podcast.artistName
        if let count = podcast.episodeCount {
            self.episodeCount = "\(count)"
        }
    }
}

extension PodcastCellViewModel: Hashable {
    static func == (lhs: PodcastCellViewModel, rhs: PodcastCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(podcastName)
        hasher.combine(artistName)
        hasher.combine(episodeCount)
    }
}
