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
    var episodeName: Published<String?>.Publisher { get }
    var episodeImage: Published<Data?>.Publisher { get }
    var description: Published<String?>.Publisher { get }
    var downloadingProgress: Published<String?>.Publisher { get }
    var isDownloadEpisodeIndicatorVisible: Published<Bool>.Publisher { get }
}
