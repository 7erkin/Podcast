//
//  EpisodeCellModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class EpisodeCellModel {
    enum Event {
        case episodeStartDownloading
        case episodeDownloadingProgressUpdated
        case episodeDownloaded
        case episodePicked
    }
    
    let episode: Episode
    var image: Data!
    var subscriber: ((Event) -> Void)?
    private var modelSubscription: Subscription!
    init(model: EpisodesModel, episodeIndex: Int) {
        episode = model.episodes[episodeIndex]
        modelSubscription = model.subscribe { [weak self] in
            switch $0 {
            case .episodeStartDownloading:
                break
            case .episodeDownloadingProgressUpdated:
                break
            case .episodePicked:
                break
            case .episodeDownloaded:
                break
            default:
                break
            }
        }
    }
    
    func fetchImage() {
        
    }
}
