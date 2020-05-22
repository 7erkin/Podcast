//
//  UserDefaultsPodcastStorage.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

// thread safe
class UserDefaultsFavoritePodcastsStorage: FavoritePodcastsStoraging {
    // MARK: - constants
    fileprivate let favoritePodcastKey = "favoritePodcastKey"
    fileprivate let serviceQueue = DispatchQueue(
        label: "user.defaults.favorite.podcast.repository",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    fileprivate var storage: UserDefaults { return UserDefaults.standard }
    // MARK: -
    private init() {
        if storage.value(forKey: favoritePodcastKey) == nil {
            let emptyPodcasts = try! JSONEncoder().encode([Podcast]())
            storage.set(emptyPodcasts, forKey: favoritePodcastKey)
        }
    }
    static var shared = UserDefaultsFavoritePodcastStorage()
    // MARK: - FavoritePodcastStoraging impl
    private(set) var podcasts: [Podcast] = []
    func download() {
        podcasts = downloadPodcasts()
        notifyAll(withEvent: .podcastsDownloaded)
    }
    
    func save(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.podcasts.isEmpty {
                self.podcasts = self.downloadPodcasts()
            }
            
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
                self.notifyAll(withEvent: .podcastDeleted(index: index))
            }
        }
    }
    // MARK: - helpers
    fileprivate func downloadPodcasts() -> [Podcast] {
        guard let serializedPodcasts = self.storage.value(forKey: self.favoritePodcastKey) as? Data else { fatalError("UB") }
        
        return [Podcast].deserialize(from: serializedPodcasts)
    }
    
    fileprivate func save(_ serializedPodcasts: Data) {
        self.storage.set(serializedPodcasts, forKey: self.favoritePodcastKey)
    }
    
    fileprivate func notifyAll(withEvent event: FavoritePodcastRepositoringEvent) {
        subscribers.values.forEach { v in v.0.async { v.1(event) } }
    }
    // MARK: - Observable impl
    private var subscribers: [UUID : (DispatchQueue, (FavoritePodcastRepositoringEvent) -> Void)] = [:]
    func subscribe(
        on serviceQueue: DispatchQueue,
        _ subscriber: @escaping (FavoritePodcastRepositoringEvent) -> Void
    ) -> Subscription {
        let key = UUID.init()
        subscribers[key] = (serviceQueue, subscriber)
        return Subscription(canceller: { [weak self] in
            self?.serviceQueue.async {
                 self?.subscribers.removeValue(forKey: key)
            }
        })
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

