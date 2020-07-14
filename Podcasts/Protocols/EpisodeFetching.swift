//
//  EpisodeFetching.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol EpisodeFetching: class {
    typealias Handler = (Result<[Episode], URLError>) -> Void
    func fetchEpisodes(url: URL, _ completionHandler: @escaping Handler)
}
