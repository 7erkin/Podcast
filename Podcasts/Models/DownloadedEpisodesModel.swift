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
    private static let trackListIdentifier = "DownloadedEpisodesTrackList"
    struct State {
        var episodeRecords: [EpisodeRecordDescriptor]
        var downloadEpisodes: [EpisodeDownload]
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
    private var currentTrackList: TrackList?
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
        if currentTrackList?.sourceIdentifier == DownloadedEpisodesModel.trackListIdentifier {
            trackListPlayer.playTrack(atIndex: index)
            return
        }
        
        let tracks = state.episodeRecords.map {
            Track(
                episode: $0.episode,
                podcast: $0.podcast,
                url: $0.recordUrl
            )
        }
        let trackList = TrackList(DownloadedEpisodesModel.trackListIdentifier, tracks: tracks, playingTrackIndex: index)
        trackListPlayer.setTrackList(trackList, reasonOfSetting: .setNewTrackList)
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
    
    private func updateWithTrackListPlayer(_ event: TrackListPlayerEvent) {
        switch event {
        case .initial(let trackList):
            currentTrackList = trackList
        case .playingTrackUpdated(let trackList):
            currentTrackList = trackList
        case .trackListUpdated(let trackList):
            currentTrackList = trackList
        }
    }
    
    func subscribe(
        _ subscriber: @escaping (DownloadedEpisodesModelEvent) -> Void
    ) -> Subscription {
        subscriber(.initial(state))
        return subscribers.subscribe(action: subscriber)
    }
}
