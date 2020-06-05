//
//  EpisodeRecordDownloading.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol EpisodeRecordDownloading: class {
    func downloadRecord(episode: Episode)
    func isRecordDownloaded(episode: Episode)
}
