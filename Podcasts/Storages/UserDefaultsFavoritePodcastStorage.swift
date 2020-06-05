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
final class UserDefaultsFavoritePodcastStorage: FavoritePodcastSaving, FavoritePodcastRemoving {
    // MARK: - constants
    fileprivate let favoritePodcastKey = "favoritePodcastKey"
    fileprivate let serviceQueue = DispatchQueue(
        label: "user.defaults.favorite.podcasts.storage",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    private var storage: UserDefaults { return UserDefaults.standard }
    private var _podcasts: [Podcast] = []
    // MARK: -
    private init() {
        if storage.value(forKey: favoritePodcastKey) == nil {
            let emptyPodcasts = try! JSONEncoder().encode([Podcast]())
            storage.set(emptyPodcasts, forKey: favoritePodcastKey)
        }
    }
    static var shared = UserDefaultsFavoritePodcastStorage()
    // MARK: - 
    func hasPodcast(_ podcast: Podcast) -> Promise<Bool> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.loadPodcastsIfNeeded()
                resolver.fulfill(self._podcasts.contains(podcast))
            }
        }
    }
    
    var podcasts: Promise<[Podcast]> {
        return Promise { resolver in
            serviceQueue.async { [weak self] in
                guard let self = self else { return }
                
                self.loadPodcastsIfNeeded()
                resolver.resolve(.fulfilled(self._podcasts))
            }
        }
    }
    
    func saveAsFavorite(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.loadPodcastsIfNeeded()
            if self._podcasts.contains(podcast) {
                return
            }
            
            if self._podcasts.isEmpty {
                self._podcasts.append(podcast)
            } else {
                self._podcasts.insert(podcast, at: 0)
            }
            
            self.save(self._podcasts.serialized)
        }
    }
    
    func removeFromFavorite(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let index = self._podcasts.firstIndex(of: podcast) {
                self._podcasts.remove(at: index)
                self.save(self._podcasts.serialized)
            }
        }
    }
    // MARK: - helpers
    fileprivate func loadPodcastsIfNeeded() {
        if _podcasts.isEmpty {
            _podcasts = loadPodcastsFromStorage()
        }
    }
    
    fileprivate func loadPodcastsFromStorage() -> [Podcast] {
        guard let serializedPodcasts = self.storage.value(forKey: self.favoritePodcastKey) as? Data else { fatalError("UB") }
        
        return [Podcast].deserialize(from: serializedPodcasts)
    }
    
    fileprivate func save(_ serializedPodcasts: Data) {
        self.storage.set(serializedPodcasts, forKey: self.favoritePodcastKey)
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

