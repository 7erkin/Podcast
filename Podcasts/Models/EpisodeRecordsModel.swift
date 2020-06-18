//
//  EpisodeRecordsModel.swift
//  Podcasts
//
//  Created by user166334 on 6/11/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

enum EpisodeRecordsModelEvent {
    case initial([EpisodeRecordDescriptor], OrderedDictionary<Episode, Double>)
    case episodeDownloadingFinishWithCancel(Episode, OrderedDictionary<Episode, Double>)
    case episodeDownloadingFinishWithError(Episode, OrderedDictionary<Episode, Double>)
    case episodeDownloaded(Episode, [EpisodeRecordDescriptor], OrderedDictionary<Episode, Double>)
    case episodeRecordRemoved(Episode, [EpisodeRecordDescriptor])
}

final class EpisodeRecordsModel {
    private var subscribers = Subscribers<EpisodeRecordsModelEvent>()
    private var subscriptions: [Subscription] = []
    private var downloadingEpisodes: OrderedDictionary<Episode, Double> = [:]
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
        _ subscriber: @escaping (EpisodeRecordsModelEvent) -> Void
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
    
    func removeEpisodeRecord(withIndex index: Int) {
        recordRepository.remove(recordDescriptor: episodeRecords[index])
    }
    
    func playEpisode(withIndex index: Int) {
        let trackList = episodeRecords.map { Track(episode: $0.episode, podcast: $0.podcast, url: $0.recordUrl) }
        trackListPlayer.setTrackList(trackList, playingTrackIndex: index)
    }
    
    func cancelEpisodeRecordDownloading(withIndex index: Int) {
        recordRepository.cancelDownloadingRecord(ofEpisode: episodeRecords[index].episode)
    }
}
