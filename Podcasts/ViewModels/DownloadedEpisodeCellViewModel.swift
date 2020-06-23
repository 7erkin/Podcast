//
//  DownloadedEpisodeCellViewModel.swift
//  Podcasts
//
//  Created by user166334 on 6/23/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class DownloadedEpisodeCellViewModel: _EpisodeCellViewModel {
    init(episode: Episode) {
        super.init(episode)
        isEpisodeDownloaded = true
    }
}
