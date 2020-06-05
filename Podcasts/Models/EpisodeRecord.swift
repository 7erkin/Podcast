//
//  EpisodeRecord.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

struct EpisodeRecord: Codable {
    var episode: Episode
    var podcast: Podcast
    var recordUrl: URL
    var dateOfCreate = Date()
}
