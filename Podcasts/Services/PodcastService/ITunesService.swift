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

class ITunesService: PodcastServicing {
    struct SearchResults: Decodable {
        let resultCount: Int
        let results: [Podcast]
    }
    
    static let shared = ITunesService()
    
    private init() {}
    
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
}
