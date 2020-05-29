//
//  UserDefaultsPodcastStorage.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit

// thread safe
final class UserDefaultsFavoritePodcastsStorage: FavoritePodcastsStoraging {
    // MARK: - constants
    fileprivate let favoritePodcastKey = "favoritePodcastKey"
    fileprivate let serviceQueue = DispatchQueue(
        label: "user.defaults.favorite.podcasts.storage",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    fileprivate var storage: UserDefaults { return UserDefaults.standard }
    fileprivate var podcasts: [Podcast] = []
    // MARK: -
    private init() {
        if storage.value(forKey: favoritePodcastKey) == nil {
            let emptyPodcasts = try! JSONEncoder().encode([Podcast]())
            storage.set(emptyPodcasts, forKey: favoritePodcastKey)
        }
    }
    static var shared = UserDefaultsFavoritePodcastsStorage()
    // MARK: - FavoritePodcastsStoraging impl
    func hasPodcast(_ podcast: Podcast) -> Promise<Bool> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.loadPodcastsIfNeeded()
                resolver.fulfill(self.podcasts.contains(podcast))
            }
        }
    }
    
    func getPodcasts() -> Promise<[Podcast]> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.loadPodcastsIfNeeded()
                resolver.resolve(.fulfilled(self.podcasts))
            }
        }
    }
    
    func save(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.loadPodcastsIfNeeded()
            if self.podcasts.contains(podcast) {
                self.notifyAll(withEvent: .podcastSaved)
                return
            }
            
            if self.podcasts.isEmpty {
                self.podcasts.append(podcast)
            } else {
                self.podcasts.insert(podcast, at: 0)
            }
            
            self.save(self.podcasts.serialized)
            self.notifyAll(withEvent: .podcastSaved)
        }
    }
    
    func delete(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let index = self.podcasts.firstIndex(of: podcast) {
                self.podcasts.remove(at: index)
                self.save(self.podcasts.serialized)
                self.notifyAll(withEvent: .podcastDeleted)
            }
        }
    }
    // MARK: - helpers
    fileprivate func loadPodcastsIfNeeded() {
        if podcasts.isEmpty {
            podcasts = loadPodcastsFromStorage()
        }
    }
    
    fileprivate func loadPodcastsFromStorage() -> [Podcast] {
        guard let serializedPodcasts = self.storage.value(forKey: self.favoritePodcastKey) as? Data else { fatalError("UB") }
        
        return [Podcast].deserialize(from: serializedPodcasts)
    }
    
    fileprivate func save(_ serializedPodcasts: Data) {
        self.storage.set(serializedPodcasts, forKey: self.favoritePodcastKey)
    }
    
    fileprivate func notifyAll(withEvent event: FavoritePodcastStoragingEvent) {
        subscribers.values.forEach { $0(event) }
    }
    // MARK: -
    private var subscribers: [UUID : (FavoritePodcastStoragingEvent) -> Void] = [:]
    func subscribe(_ subscriber: @escaping (FavoritePodcastStoragingEvent) -> Void) -> Promise<Subscription> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                let key = UUID.init()
                self?.subscribers[key] = subscriber
                let subscription = Subscription { [weak self] in
                    self?.serviceQueue.async {
                         self?.subscribers.removeValue(forKey: key)
                    }
                }
                resolver.resolve(.fulfilled(subscription))
            }
        }
    }
}

fileprivate extension Array where Element == Podcast {
    var serialized: Data {
        return try! JSONEncoder().encode(self)
    }
    static func deserialize(from data: Data) -> Self {
        return try! JSONDecoder().decode(Self.self, from: data)
    }
}

