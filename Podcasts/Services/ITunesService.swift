//
//  APIService.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit
import PromiseKit

final class ITunesService: EpisodeFetching, PodcastFetching, EpisodeRecordFetching {
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    static let shared = ITunesService()
    func fetchEpisodes(url: URL, _ completionHandler: @escaping ([Episode]) -> Void) {
        let secureFeedUrl = url.isSecure ? url : url.secured
        let parser = FeedParser(URL: secureFeedUrl)
        parser.parseAsync { result in
            switch result {
            case .success(let feed):
                switch feed {
                case .rss(let rssFeed):
                    completionHandler(rssFeed.toEpisodes)
                default:
                    break
                }
            case .failure(_):
                break
            }
        }
    }
    
    func fetchPodcasts(searchText: String, _ completionHandler: @escaping ([Podcast]) -> Void) {
        let url = "https://itunes.apple.com/search?term=\(searchText)&media=podcast"
        let parameters: [String:Any] = ["term": searchText, "media": "podcast"]
        AF.request(url).response { (dataResponse) in
            if let err = dataResponse.error {
                return
            }
            guard let data = dataResponse.data else { return }
            
            do {
                let searchResults = try JSONDecoder().decode(SearchResults.self, from: data)
                completionHandler(searchResults.results)
            } catch let decodeErr {
                
            }
        }
    }
    
    func fetchEpisodeRecord(
        episode: Episode,
        _ progressHandler: ((Double) -> Void)?,
        _ completionHandler: @escaping (Data) -> Void
    ) {
        return  Promise { resolver in
            let downloadRequest = AF.download(episode.streamUrl)
            downloadRequest.downloadProgress { progress in
                progressHandler?(progress.fractionCompleted)
            }
            downloadRequest.responseData { dataResponse in
                if let _ = dataResponse.error {
                    resolver.reject(BreakPromiseChainError())
                    return
                }
                
                guard let data = dataResponse.value else {
                    resolver.reject(BreakPromiseChainError())
                    return
                }
                
                resolver.fulfill(data)
            }
        }
    }
}
