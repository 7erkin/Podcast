//
//  Episode.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import FeedKit

struct Episode: Equatable {
    var name: String
    var author: String
    var publishDate: Date
    var description: String
    var streamUrl: URL
    
    var imageUrl: URL?
    
    init(rssFeedItem: RSSFeedItem) {
        name = rssFeedItem.title ?? ""
        author = rssFeedItem.author ?? ""
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
