//
//  EpisodeCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

final class EpisodeCellViewModel {
    var publishDate = ObservedValue<String?>(nil)
    var episodeName = ObservedValue<String?>(nil)
    var description = ObservedValue<String?>(nil)
    var progress = ObservedValue<String?>(nil)
    var episodeImage = ObservedValue<UIImage?>(nil)
    var isLoadingEpisodeImageIndicatorActive = ObservedValue<Bool>(false)
    var isEpisodeDownloadIndicatorHidden = ObservedValue<Bool>(false)
    
    private let model: EpisodeCellModel
    private var timer: Timer?
   
    init(model: EpisodeCellModel) {
        self.model = model
        model.subscriber = { [unowned self] in self.updateWithModel(withEvent: $0) }
        let episode = model.episode
        episodeName.value = episode.name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        publishDate.value = dateFormatter.string(from: episode.publishDate)
        description.value = episode.description
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func fetchImage(withSize imageSize: CGSize) {
        timer = Timer(timeInterval: 1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.model.fetchImage()
        }
        timer?.tolerance = 0.2
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateWithModel(withEvent event: EpisodeCellModel.Event) {
        switch event {
        case .episodeDownloaded:
            progress.value = nil
            isEpisodeDownloadIndicatorHidden.value = false
            break
        case .episodeDownloadingProgressUpdated:
            break
        case .episodePicked:
            break
        default:
            break
        }
    }
}
