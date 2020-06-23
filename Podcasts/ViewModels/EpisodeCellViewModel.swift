//
//  EpisodeCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class EpisodeCellViewModel: _EpisodeCellViewModel {
    private let model: EpisodeModel
    private var subscriptions: [Subscription] = []
    init(model: EpisodeModel) {
        self.model = model
        super.init()
        self.model
            .subscribe { [weak self] in self?.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    private func updateWithModel(_ event: EpisodeModelEvent) {
        switch event {
        case .initial(let episode, let downloadingStatus):
            // must be fixed
            imageUrl = episode.imageUrl!
            episodeName = episode.name
            publishDate = Episode.dateFormatter.string(from: episode.publishDate)
            description = episode.description
            updateWithDownloadingStatus(downloadingStatus)
        case .episodeDownloadingStatusChanged(let downloadingStatus):
            updateWithDownloadingStatus(downloadingStatus)
        }
    }
    
    private func updateWithDownloadingStatus(_ status: EpisodeDownloadingStatus) {
        switch status {
        case .downloaded:
            isEpisodeDownloaded = true
            progress = nil
        case .notStarted:
            isEpisodeDownloaded = false
            progress = nil
        case .inProgress(let progress):
            self.progress = "\(progress)"
        default:
            break
        }
    }
    
    func downloadEpisode() {
        model.downloadEpisode()
    }
    
    func cancelEpisodeDownloading() {
        model.cancelEpisodeDownloading()
    }
}
