//
//  _EpisodeCellViewModel.swift
//  Podcasts
//
//  Created by user166334 on 6/23/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

class _EpisodeCellViewModel: EpisodeCellOutput, Hashable {
    // MARK: - EpisodeCellOutput
    var publishDatePublisher: Published<String?>.Publisher { $publishDate }
    var episodeNamePublisher: Published<String?>.Publisher { $episodeName }
    var descriptionPublisher: Published<String?>.Publisher { $description }
    var downloadingProgressPublisher: Published<String?>.Publisher { $progress }
    var isEpisodeDownloadedPublisher: Published<Bool>.Publisher { $isEpisodeDownloaded }
    var episodeImageUrlPublisher: Published<URL?>.Publisher { $episodeImageUrl }
    
    @Published var publishDate: String?
    @Published var episodeName: String?
    @Published var description: String?
    @Published var progress: String? = ""
    @Published var isEpisodeDownloaded: Bool = true
    @Published var episodeImageUrl: URL?

    let episode: Episode
    // MARK: - Hashable
    static func == (lhs: _EpisodeCellViewModel, rhs: _EpisodeCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(episode)
    }
    // MARK: - 
    init(_ episode: Episode) {
        self.episode = episode
        episodeImageUrl = episode.imageUrl
        episodeName = episode.name
        publishDate = Episode.dateFormatter.string(from: episode.publishDate)
        description = episode.description
    }
}
