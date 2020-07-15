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
    @Published var downloadEpisodeViewModels: [EpisodeCellViewModel] = []
    @Published var episodeRecordViewModels: [DownloadedEpisodeCellViewModel] = []
    
    private let model: DownloadedEpisodesModel
    private var subscriptions: [Subscription] = []
    init(model: DownloadedEpisodesModel) {
        self.model = model
        self.model
            .subscribe { [unowned self] in self.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func playEpisode(withIndex index: Int) {
        model.playEpisode(withIndex: index)
    }
    
    private func updateWithModel(_ event: DownloadedEpisodesModelEvent) {
        switch event {
        case .initial(let state):
            downloadEpisodeViewModels = state.downloadEpisodes.map {
                EpisodeCellViewModel(
                    model: .init(
                        episode: $0.episode,
                        podcast: $0.podcast,
                        recordRepository: ServiceLocator.recordRepository
                    )
                )
            }
            
            episodeRecordViewModels = state.episodeRecords.map { DownloadedEpisodeCellViewModel(episode: $0.episode) }
        case .downloaded(let episode, _):
            if let index = downloadEpisodeViewModels.firstIndex(where: { $0.episode == episode }) {
                downloadEpisodeViewModels.remove(at: index)
            }
            episodeRecordViewModels.append(.init(episode: episode))
        case .downloadStarted(let episode, let podcast, _):
            downloadEpisodeViewModels.append(.init(model: .init(episode: episode, podcast: podcast, recordRepository: ServiceLocator.recordRepository)))
        case .downloadFinishWithCancel(let episode, _):
            if let index = downloadEpisodeViewModels.firstIndex(where: { $0.episode == episode }) {
                downloadEpisodeViewModels.remove(at: index)
            }
        case .downloadFinishWithError(let episode, _):
            if let index = downloadEpisodeViewModels.firstIndex(where: { $0.episode == episode }) {
                downloadEpisodeViewModels.remove(at: index)
            }
        case .recordRemoved(let episode, _):
            if let index = episodeRecordViewModels.firstIndex(where: { $0.episode == episode }) {
                episodeRecordViewModels.remove(at: index)
            }
        }
    }
}
