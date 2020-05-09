//
//  Podcast.swift
//  Podcasts
//
//  Created by Олег Черных on 05/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var name: String?
    var artistName: String?
    var imageUrl: URL?
    var episodeCount: Int?
    var feedUrl: URL?
    
    enum CodingKeys: String, CodingKey {
        case name = "trackName"
        case artistName
        case imageUrl = "artworkUrl600"
        case episodeCount = "trackCount"
        case feedUrl
    }
}


