//
//  FavoritePodcastsModel.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

final class FavoritePodcastsModel {
    private(set) var podcasts: [Podcast] = []
    private var storageSubscription: Subscription!
    private let storage: FavoritePodcastsStoraging
    var subscriber: ((Event) -> Void)!
    init(favoritePodcastsStorage: FavoritePodcastSaving) {
        self.storage = favoritePodcastsStorage
        subscribeToFavoritePodcastsStorage()
    }
    
    func initialize() {
    }
    
    func deletePodcast(podcastIndex index: Int) {
        storage.delete(podcast: podcasts[index])
    }
    
    private func subscribeToFavoritePodcastsStorage() {
        storage.subscribe { event in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch event {
                case .podcastSaved:
                    firstly {
                        self.updatePodcastsWithStorage()
                    }.done {
                        self.subscriber(.podcastSaved)
                    }.catch { _ in }
                    break
                case .podcastDeleted:
                    firstly {
                        self.updatePodcastsWithStorage()
                    }.done {
                        self.subscriber(.podcastDeleted)
                    }.catch { _ in }
                    break
                }
            }
        }.done { subscription in
            self.storageSubscription = subscription
        }.catch { _ in }
    }
    
    private func updatePodcastsWithStorage() -> Promise<Void> {
        firstly {
            storage.getPodcasts()
        }.then { podcasts -> Promise<Void> in
            self.podcasts = podcasts
            return Promise.value
        }
    }
}
