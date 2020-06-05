//
//  EpisodeRecordSaving.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

protocol EpisodeRecordSaving: class, EpisodeRecordProviding {
    func save(recordData: Data) -> Promise<Void>
}
