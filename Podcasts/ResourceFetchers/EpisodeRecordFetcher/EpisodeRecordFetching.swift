//
//  EpisodeRecordsDownloading.swift
//  Podcasts
//
//  Created by Олег Черных on 22/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit
import Foundation

protocol EpisodeRecordFetching {
    func fetch(episode: Episode, _ progressHandler: ((Double) -> Void)?) -> Promise<Data>
}
