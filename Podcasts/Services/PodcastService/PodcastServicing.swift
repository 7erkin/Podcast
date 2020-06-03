//
//  PodcastServicing.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

protocol PodcastServicing {
    func fetchEpisodes(url: URL, _ completionHandler: @escaping ([Episode]) -> Void)
    func fetchPodcasts(searchText: String, _ completionHandler: @escaping ([Podcast]) -> Void)
    func fetchRecord(episode: Episode, _ progressHandler: ((Double) -> Void)?) -> Promise<Data>
}
