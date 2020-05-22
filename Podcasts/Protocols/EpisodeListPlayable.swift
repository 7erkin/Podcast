//
//  EpisodeListPlayable.swift
//  Podcasts
//
//  Created by user166334 on 5/22/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

enum EpisodeListPlayableEvent: AppEvent {
    case playingEpisodeChanged(playedEpisode: PlayedEpisode)
}

protocol EpisodeListPlayable: class {
    func play(episodeByIndex episodeIndex: Int, inEpisodeList episodes: [Episode], of podcast: Podcast)
}
