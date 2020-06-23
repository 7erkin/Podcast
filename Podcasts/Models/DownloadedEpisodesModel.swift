//
//  EpisodeRecordsModel.swift
//  Podcasts
//
//  Created by user166334 on 6/11/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum DownloadedEpisodesModelEvent {
    case initial([EpisodeRecordDescriptor], [CurrentDownloadEpisode])
    case episodeDownloadingFinishWithCancel(Episode, [CurrentDownloadEpisode])
    case episodeDownloadingFinishWithError(Episode, [CurrentDownloadEpisode])
    case episodeDownloaded(Episode, [EpisodeRecordDescriptor], [CurrentDownloadEpisode])
    case episodeRecordRemoved(Episode, [EpisodeRecordDescriptor])
}

final class DownloadedEpisodesModel {
    private var subscribers = Subscribers<DownloadedEpisodesModelEvent>()
    private var subscriptions: [Subscription] = []
    private var downloadingEpisodes: [CurrentDownloadEpisode] = []
    private var episodeRecords: [EpisodeRecordDescriptor] = []
    // MARK: - dependencies
    private let recordRepository: EpisodeRecordRepositoring
    private let trackListPlayer: TrackListPlaying
    // MARK: -
    init(
        recordRepository: EpisodeRecordRepositoring,
        trackListPlayer: TrackListPlaying
    ) {
        self.recordRepository = recordRepository
        self.trackListPlayer = trackListPlayer
        self.recordRepository
            .subscribe { [weak self] in self?.updateWithRecordRepository($0) }
            .stored(in: &subscriptions)
        self.trackListPlayer
            .subscribe { [weak self] in self?.updateWithTrackListPlayer($0) }
            .stored(in: &subscriptions)
    }
    
    func subscribe(
        _ subscriber: @escaping (DownloadedEpisodesModelEvent) -> Void
    ) -> Subscription {
        subscriber(.initial(episodeRecords, downloadingEpisodes))
        return subscribers.subscribe(action: subscriber)
    }
    
    private func updateWithRecordRepository(_ event: EpisodeRecordRepositoryEvent) {
        switch event {
        case .initial(let episodeRecords, let downloadingEpisodes):
            self.episodeRecords = episodeRecords
            self.downloadingEpisodes = downloadingEpisodes
            subscribers.fire(.initial(self.episodeRecords, self.downloadingEpisodes))
        default:
            break
        }
    }
    
    private func updateWithTrackListPlayer(_ event: TrackListPlayerEvent) {}
    
    func removeEpisodeRecord(_ episode: Episode) {
        guard let index = episodeRecords.firstIndex(where: { $0.episode == episode }) else { fatalError() }
        
        recordRepository.remove(recordDescriptor: episodeRecords[index])
    }
    
    func playEpisode(withIndex index: Int) {
        let trackList = episodeRecords.map { Track(episode: $0.episode, podcast: $0.podcast, url: $0.recordUrl) }
        trackListPlayer.setTrackList(trackList, withPlayingTrackIndex: index)
    }
    
    func cancelEpisodeRecordDownloading(withIndex index: Int) {
        recordRepository.cancelDownloadingRecord(ofEpisode: episodeRecords[index].episode)
    }
}
