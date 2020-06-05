//
//  EpisodeRecordFetching.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol EpisodeRecordFetching: class {
    func fetchEpisodeRecord(
        episode: Episode,
        _ progressHandler: ((Double) -> Void)?,
        _ completionHandler: @escaping (Data) -> Void
    )
}
