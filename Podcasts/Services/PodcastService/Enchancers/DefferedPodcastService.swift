//
//  DefferedRequestPodcastServicingDecorator.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class DefferedPodcastService: PodcastServicing {
    private let wrappedPodcastService: PodcastServicing
    private var timer: Timer?
    private let timeout: TimeInterval
    init(timeout: TimeInterval, wrappedPodcastService podcastService: PodcastServicing) {
        wrappedPodcastService = podcastService
        self.timeout = timeout
    }
    
    func fetchEpisodes(url: URL, _ completionHandler: @escaping ([Episode]) -> Void) {
        let closure: () -> Void = { [weak self] in self?.wrappedPodcastService.fetchEpisodes(url: url, completionHandler)}
        defferedCall(closure)
    }
    
    func fetchPodcasts(searchText: String, _ completionHandler: @escaping ([Podcast]) -> Void) {
        let closure: () -> Void = { [weak self] in self?.wrappedPodcastService.fetchPodcasts(searchText: searchText, completionHandler) }
        defferedCall(closure)
    }
    
    func fetchRecord(episode: Episode, _ progressHandler: ((Double) -> Void)?) -> Promise<Data> {
        return self.wrappedPodcastService.fetchRecord(episode: episode, progressHandler)
    }
    
    fileprivate func defferedCall(_ method: @escaping () -> Void) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in method() }
    }
}
