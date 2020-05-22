//
//  DownloadedPodcastRepositoring.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

protocol EpisodeRecordsStoraging {
    @discardableResult
    func save(episode: Episode, withRecord record: Data) -> Promise<Void>
    @discardableResult
    func delete(episode: Episode) -> Promise<Void>
    func getEpisodeRecord(_ episode: Episode) -> Promise<Data>
    func getStoredEpisodesInfo() -> Promise<[Episode]>
}
