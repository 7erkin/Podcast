//
//  EpisodeRecordFetching.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class DownloadManager {
    typealias Handler = () -> Void
    let cancel: Handler
    let resume: Handler
    let suspend: Handler
    init(cancel: @escaping Handler, resume: @escaping Handler, suspend: @escaping Handler) {
        self.cancel = cancel
        self.resume = resume
        self.suspend = suspend
    }
}

enum EpisodeRecordDownloadEvent {
    case inProgress(Double)
    case fulfilled(URL)
    case suspended
    case started
    case canceled
    case resumed
}

enum EpisodeRecordDownloadResult {
    case event(EpisodeRecordDownloadEvent)
    case failure(URLError)
}

protocol EpisodeRecordDownloading: class {
    typealias Handler = (EpisodeRecordDownloadResult) -> Void
    func downloadEpisodeRecord(
        episode: Episode,
        _ block: @escaping Handler
    ) -> Promise<DownloadManager>
}
