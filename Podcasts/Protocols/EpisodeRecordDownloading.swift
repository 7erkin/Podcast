//
//  EpisodeRecordFetching.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

struct EpisodeDownload {
    var episode: Episode
    var progress: Double
}

enum EpisodeRecordDownloaderEvent {
    case progressUpdated(Episode, EpisodeRecordDownloaderState)
    case fulfilled(Episode, URL, EpisodeRecordDownloaderState)
    case started(Episode, EpisodeRecordDownloaderState)
    case cancelled(Episode, EpisodeRecordDownloaderState)
    case recovered([Episode], EpisodeRecordDownloaderState)
}

struct EpisodeRecordDownloaderState {
    var downloads: [EpisodeDownload]
    
    subscript(episode: Episode) -> EpisodeDownload? {
        downloads.first(where: { $0.episode == episode })
    }
}

protocol EpisodeRecordDownloading: class {
    var publisher: AnyPublisher<EpisodeRecordDownloaderEvent, Never> { get }
    func downloadEpisodeRecord(_ episode: Episode)
    func cancelEpisodeRecordDownload(_ episode: Episode)
}
