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
        super.init(model.episode)
        self.model
            .subscribe { [weak self] in self?.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    private func updateWithModel(_ event: EpisodeModelEvent) {
        switch event {
        case .initial(let episode, let downloadingStatus):
            episodeImageUrl = episode.imageUrl
            episodeName = episode.name
            publishDate = Episode.dateFormatter.string(from: episode.publishDate)
            description = episode.description
            updateWithDownloadingStatus(downloadingStatus)
        case .episodeDownloadingStatusChanged(let downloadingStatus):
            updateWithDownloadingStatus(downloadingStatus)
        }
    }
    
    private func updateWithDownloadingStatus(_ status: EpisodeDownloadStatus) {
        switch status {
        case .downloaded:
            isEpisodeDownloaded = true
            progress = nil
        case .downloadNotLaunched:
            isEpisodeDownloaded = false
            progress = nil
        case .inProgress(let progress):
            self.progress = "\(Int(progress * 100))%"
        case .finishedWithCancelation:
            self.progress = nil
            isEpisodeDownloaded = false
        case .finishedWithError:
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
