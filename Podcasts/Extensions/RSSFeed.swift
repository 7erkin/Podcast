//
//  RSSFeed.swift
//  Podcasts
//
//  Created by Олег Черных on 06/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import FeedKit

extension RSSFeed {
    var toEpisodes: [Episode] {
        return self.items?.map { Episode(rssFeedItem: $0) } ?? []
    }
}
