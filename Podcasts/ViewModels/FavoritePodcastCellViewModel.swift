//
//  FavoritePodcastCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 17/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class FavoritePodcastCellViewModel: ObservableObject {
    @Published var artistName: String?
    @Published var podcastName: String?
    @Published var podcastImage: Data?
    private var subscriptions: Set<AnyCancellable> = []
    init(podcast: Podcast) {
        artistName = podcast.artistName
        podcastName = podcast.name
        // how to start image download when subscriber appears? Not in init(:Podcast) as it now
        if let imageUrl = podcast.imageUrl {
        }
    }
}
