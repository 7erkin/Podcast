//
//  FavoritePodcastProviding.swift
//  Podcasts
//
//  Created by user166334 on 6/5/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit

protocol FavoritePodcastProviding: class {
    var podcasts: Promise<[Podcast]> { get }
    func hasPodcast(_ podcast: Podcast) -> Promise<Bool>
}
