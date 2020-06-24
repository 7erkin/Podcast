//
//  EpisodeCellOutput.swift
//  Podcasts
//
//  Created by user166334 on 6/18/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

protocol EpisodeCellOutput: class {
    var publishDatePublisher: Published<String?>.Publisher { get }
    var episodeNamePublisher: Published<String?>.Publisher { get }
    var episodeImageUrlPublisher: Published<URL?>.Publisher { get }
    var descriptionPublisher: Published<String?>.Publisher { get }
    var downloadingProgressPublisher: Published<String?>.Publisher { get }
    var isEpisodeDownloadedPublisher: Published<Bool>.Publisher { get }
}
