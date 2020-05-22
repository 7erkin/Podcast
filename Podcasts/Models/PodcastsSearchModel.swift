//
//  PodcastsSearchModel.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

class PodcastsSearchModel {
    enum Event {
        case podcastsFetched
    }
    
    private let podcastService: PodcastServicing
    private(set) var podcasts: [Podcast] = []
    var subscriber: ((Event) -> Void)!
    init(podcastService: PodcastServicing) {
        self.podcastService = podcastService
    }
    
    func fetchPodcasts(bySearchText searchText: String) {
        podcastService.fetchPodcasts(searchText: searchText) { [weak self] podcasts in
            // Question in Trello
            DispatchQueue.main.async {
                self?.podcasts = podcasts
                self?.subscriber(.podcastsFetched)
            }
        }
    }
}
