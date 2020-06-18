//
//  EpisodeCellViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 03/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class EpisodeCellViewModel: ObservableObject {
    @Published var publishDate: String?
    @Published var episodeName: String?
    @Published var description: String?
    @Published var progress: String?
    @Published var episodeImage: Data?
    @Published var isEpisodeDownloaded: Bool?
    
    private let model: EpisodeCellModel
    private var timer: Timer?
    
    private var subscriptions: [Subscription] = []
   
    init(model: EpisodeCellModel) {
        self.model = model
        self.model
            .subscribe { [weak self] in self?.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func updateWithModel(_ event: EpisodeCellModelEvent) {
        switch event {
        case .initial(let episode, let downloadingStatus):
            episodeName = episode.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            publishDate = dateFormatter.string(from: episode.publishDate)
            description = episode.description
            updateWithDownloadingStatus(downloadingStatus)
        case .episodeDownloadingStatusChanged(let downloadingStatus):
            updateWithDownloadingStatus(downloadingStatus)
        }
    }
    
    private func updateWithDownloadingStatus(_ status: EpisodeDownloadingStatus) {
        switch status {
        case .downloaded:
            isEpisodeDownloaded = true
            progress = nil
        case .notStarted:
            isEpisodeDownloaded = false
            progress = nil
        case .inProgress(let progress):
            self.progress = "\(progress)"
        default:
            break
        }
    }
    
    func fetchImage(withSize imageSize: CGSize) {
        timer = Timer(timeInterval: 1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
        }
        timer?.tolerance = 0.2
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func downloadEpisode() {
        model.downloadEpisode()
    }
    
    func cancelEpisodeDownloading() {
        model.cancelEpisodeDownloading()
    }
}
