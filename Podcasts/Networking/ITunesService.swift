//
//  APIService.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import FeedKit
import UIKit

final class ITunesService: EpisodeFetching, PodcastFetching {
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    static let shared = ITunesService()
    // MARK: - EpisodeFetching
    func fetchEpisodes(url: URL, _ completionHandler: @escaping EpisodeFetching.Handler) {
        let secureFeedUrl = url.isSecure ? url : url.secured
        let parser = FeedParser(URL: secureFeedUrl)
        parser.parseAsync { result in
            switch result {
            case .success(let feed):
                switch feed {
                case .rss(let rssFeed):
                    completionHandler(.success(rssFeed.toEpisodes))
                default:
                    break
                }
            case .failure(_):
                break
            }
        }
    }
    // MARK: - PodcastFetching
    func fetchPodcasts(
        searchText: String,
        _ completionHandler: @escaping PodcastFetching.Handler
    ) {
        guard
            let url = URLComponents.create(
                string: "https://itunes.apple.com/search",
                withQueryItems: [
                    .init(name: "term", value: searchText),
                    .init(name: "media", value: "podcast")
                ]
            )?.url
        else {
            fatalError("Not implemented")
        }
    
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadRevalidatingCacheData,
            timeoutInterval: 2.0
        )
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                return
            }
            
            if
                let httpResponse = response as? HTTPURLResponse,
                (200..<299).contains(httpResponse.statusCode),
                let data = data,
                let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data)
            {
                completionHandler(.success(searchResults.results))
            } else {
            }
        }
        task.resume()
    }
}
