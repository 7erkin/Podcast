//
//  EpisodeRecordsModel.swift
//  Podcasts
//
//  Created by user166334 on 6/11/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum DownloadedEpisodesModelEvent {
    case initial(DownloadedEpisodesModel.State)
    case downloaded(Episode, DownloadedEpisodesModel.State)
    case downloadStarted(Episode, Podcast, DownloadedEpisodesModel.State)
    case downloadFinishWithCancel(Episode, DownloadedEpisodesModel.State)
    case downloadFinishWithError(Episode, DownloadedEpisodesModel.State)
    case recordRemoved(Episode, DownloadedEpisodesModel.State)
}

final class DownloadedEpisodesModel {
    struct State {
        var episodeRecords: [EpisodeRecordDescriptor]
        var downloadEpisodes: [DownloadEpisode]
        init() {
            self.episodeRecords = []
            self.downloadEpisodes = []
        }
        
        init(_ episodesDownloads: EpisodesDownloads) {
            episodeRecords = episodesDownloads.fulfilled
            downloadEpisodes = episodesDownloads.active
        }
    }
    private var subscribers = Subscribers<DownloadedEpisodesModelEvent>()
    private var subscriptions: [Subscription] = []
    private var state: State
    // MARK: - dependencies
    private let recordRepository: EpisodeRecordRepositoring
    private let trackListPlayer: TrackListPlaying
    // MARK: -
    init(
        recordRepository: EpisodeRecordRepositoring,
        trackListPlayer: TrackListPlaying
    ) {
        state = .init()
        self.recordRepository = recordRepository
        self.trackListPlayer = trackListPlayer
        self.recordRepository
            .subscribe { [weak self] in self?.updateWithRecordRepository($0) }
            .stored(in: &subscriptions)
        self.trackListPlayer
            .subscribe { [weak self] in self?.updateWithTrackListPlayer($0) }
            .stored(in: &subscriptions)
    }
    
    func playEpisode(withIndex index: Int) {
        let trackList = state.episodeRecords.map { Track(episode: $0.episode, podcast: $0.podcast, url: $0.recordUrl) }
        trackListPlayer.setTrackList(trackList, withPlayingTrackIndex: index)
    }
    
    private func updateWithRecordRepository(_ event: EpisodeRecordRepositoryEvent) {
        switch event {
        case .initial(let episodesDownloads):
            state = .init(episodesDownloads)
            subscribers.fire(.initial(state))
        case .downloadStarted(let episode, let podcast, let episodesDownloads):
            state = .init(episodesDownloads)
            subscribers.fire(.downloadStarted(episode, podcast, state))
        case .downloadCancelled(let episode, _, let episodesDownloads):
            state = .init(episodesDownloads)
            subscribers.fire(.downloadFinishWithCancel(episode, state))
        case .download(let episodesDownloads):
            state = .init(episodesDownloads)
        case .downloadFulfilled(let episode, _, let episodesDownloads):
            state = .init(episodesDownloads)
            subscribers.fire(.downloaded(episode, state))
        case .removed(let recordDescriptor, let episodesDownloads):
            state = .init(episodesDownloads)
            subscribers.fire(.recordRemoved(recordDescriptor.episode, state))
        default:
            break
        }
    }
    
    private func updateWithTrackListPlayer(_ event: TrackListPlayerEvent) {}
    
    func subscribe(
        _ subscriber: @escaping (DownloadedEpisodesModelEvent) -> Void
    ) -> Subscription {
        subscriber(.initial(state))
        return subscribers.subscribe(action: subscriber)
    }
}
