//
//  DownloadedPodcastRepositoring.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

struct StoredEpisodeItem: Codable {
    var episode: Episode
    var podcast: Podcast
    var recordUrl: URL
}

protocol EpisodeRecordsStoraging {
    @discardableResult
    func save(episode: Episode, ofPodcast podcast: Podcast, withRecord record: Data) -> Promise<Void>
    @discardableResult
    func delete(episode: Episode) -> Promise<Void>
    func getStoredEpisodeRecordItem(_ episode: Episode) -> Promise<StoredEpisodeItem>
    func getStoredEpisodeRecordList() -> Promise<[StoredEpisodeItem]>
    func hasEpisode(_ episode: Episode) -> Promise<Bool>
}
