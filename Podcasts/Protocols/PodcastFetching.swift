//
//  PodcastFetching.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol PodcastFetching: class {
    typealias Handler = (Result<[Podcast], URLError>) -> Void
    func fetchPodcasts(
        searchText: String,
        _ completionHandler: @escaping Handler
    )
}
