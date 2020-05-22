//
//  SQLEpisodeRecordStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

class SQLEpisodeRecordsStorage: EpisodeRecordsStoraging {
    static var shared = SQLEpisodeRecordsStorage()
    private init() {}
    
    func save(episode: Episode, withRecord record: Data) -> Promise<Void> {
        fatalError("Not implemented")
    }
    
    func delete(episode: Episode) -> Promise<Void> {
        fatalError("Not implemented")
    }
    
    func getEpisodeRecord(_ episode: Episode) -> Promise<Data> {
        fatalError("Not implemented")
    }
    
    func getStoredEpisodesInfo() -> Promise<[Episode]> {
        fatalError("Not implemented")
    }
}
