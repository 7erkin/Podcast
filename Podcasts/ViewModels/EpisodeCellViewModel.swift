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

final class EpisodeCellViewModel {
    @Published var publishDate: String?
    @Published var episodeName: String?
    @Published var description: String?
    @Published var progress: String?
    var episodeImage: AnyPublisher<Data, URLError> {
        URLSession.shared
            .dataTaskPublisher(for: imageUrl)
            .map(\.data)
            .eraseToAnyPublisher()
    }
    @Published var isEpisodeDownloaded: Bool = false
    
    private var imageUrl: URL!
    private let model: EpisodeCellModel
    private var timer: Timer?
    // fileprivate because of extension in the same file
    fileprivate let identifier = UUID()
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
            // must be fixed
            imageUrl = episode.imageUrl!
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
    
    func downloadEpisode() {
        model.downloadEpisode()
    }
    
    func cancelEpisodeDownloading() {
        model.cancelEpisodeDownloading()
    }
}

extension EpisodeCellViewModel: Hashable {
    static func == (lhs: EpisodeCellViewModel, rhs: EpisodeCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
