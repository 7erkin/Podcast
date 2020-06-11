//
//  PodcastsSearchModel.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class PodcastsSearchModel {
    private let podcastFetcher: PodcastFetching
    private(set) var podcasts: [Podcast] = []
    init(podcastFetcher: PodcastFetching) {
        self.podcastFetcher = podcastFetcher
    }
    
    func fetchPodcasts(bySearchText searchText: String) {
        podcastFetcher.fetchPodcasts(searchText: searchText) { [weak self] podcasts in
            DispatchQueue.main.async {
                self?.podcasts = podcasts
            }
        }
    }
}
