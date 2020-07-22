//
//  PodcastsSearchModel.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class PodcastsSearchViewModel {
    @Published private(set) var podcastCellViewModels: [PodcastCellViewModel] = []
    private let podcastFetcher: PodcastFetching
    init(podcastFetcher: PodcastFetching) {
        self.podcastFetcher = podcastFetcher
    }
    
    func findPodcasts(bySearchText searchText: String) {
        podcastFetcher.fetchPodcasts(searchText: searchText) { [weak self] result in
            switch result {
            case .success(let podcasts):
                self?.podcastCellViewModels = podcasts.map { PodcastCellViewModel(podcast: $0) }
            case .failure(_):
                break
            }
        }
    }
}
