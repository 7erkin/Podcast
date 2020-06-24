//
//  DownloadedEpisodesViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 20/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class DownloadedEpisodesViewModel {
    @Published var downloadingEpisodes: [EpisodeCellViewModel] = []
    @Published var downloadedEpisodes: [DownloadedEpisodeCellViewModel] = []
    private let model: DownloadedEpisodesModel
    private var subscriptions: [Subscription] = []
    init(model: DownloadedEpisodesModel) {
        self.model = model
        self.model
            .subscribe { [unowned self] in self.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func removeEpisodeRecord(_ episode: Episode) {
        model.removeEpisodeRecord(episode)
    }
    
    private func updateWithModel(_ event: DownloadedEpisodesModelEvent) {
        switch event {
        case .initial(let episodeRecords, let downloadingEpisodes):
            self.downloadingEpisodes = downloadingEpisodes.keys.map {
                EpisodeCellViewModel(
                    model: EpisodeModel(
                        episode: $0,
                        podcast: downloadingEpisodes[$0]!.podcast,
                        recordRepository: ServiceLocator.recordRepository
                    )
                )
            }
            downloadedEpisodes = episodeRecords.map { DownloadedEpisodeCellViewModel(episode: $0.episode) }
        case .episodeRecordRemoved(_, let episodeRecords):
            downloadedEpisodes = episodeRecords.map { DownloadedEpisodeCellViewModel(episode: $0.episode) }
        default:
            break
        }
    }
}
