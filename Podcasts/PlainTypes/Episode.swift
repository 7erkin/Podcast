//
//  Episode.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Codable, Equatable {
    var name: String
    var author: String
    var publishDate: Date
    var description: String
    var streamUrl: URL
    
    var fileUrl: URL?
    var imageUrl: URL?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.streamUrl == rhs.streamUrl
    }
    
    init(rssFeedItem: RSSFeedItem) {
        name = rssFeedItem.title ?? ""
        author = rssFeedItem.iTunes?.iTunesAuthor ?? ""
        publishDate = rssFeedItem.pubDate ?? Date()
        description = rssFeedItem.description ?? ""
        streamUrl = URL(string: rssFeedItem.enclosure?.attributes?.url ?? "")!
        if let href = rssFeedItem.iTunes?.iTunesImage?.attributes?.href {
            imageUrl = URL(string:  href)
        } else {
            imageUrl = Bundle.main.url(forResource: "podcast", withExtension: "jpeg")
        }
    }
}

extension Episode: Hashable {}
