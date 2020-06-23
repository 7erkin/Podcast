//
//  UserDefaultsPodcastStorage.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class UserDefaultsFavoritePodcastStorage: FavoritePodcastsStoraging {
    // MARK: - constants
    fileprivate let favoritePodcastKey = "favoritePodcastKey"
    fileprivate let serviceQueue = DispatchQueue(
        label: "favorite.podcasts.storage",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem,
        target: nil
    )
    // MARK: -
    private var podcasts: [Podcast]
    private var subscribers = Subscribers<FavoritePodcastsStorageEvent>()
    init() {
        if let podcasts: [Podcast] = UserDefaults.standard.extract(withKey: favoritePodcastKey) {
            self.podcasts = podcasts
        } else {
            let podcasts = try! JSONEncoder().encode([Podcast]())
            UserDefaults.standard.set(podcasts, forKey: favoritePodcastKey)
            self.podcasts = []
        }
    }
    // MARK: - FavoritePodcastStoraging
    func saveAsFavorite(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.podcasts.contains(podcast) { return }
            
            if self.podcasts.isEmpty {
                self.podcasts.append(podcast)
            } else {
                self.podcasts.insert(podcast, at: 0)
            }
            
            UserDefaults.standard.set(self.podcasts.serialized, forKey: self.favoritePodcastKey)
            self.subscribers.fire(.saved(podcast, self.podcasts))
        }
    }
    
    func removeFromFavorites(podcast: Podcast) {
        serviceQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let index = self.podcasts.firstIndex(of: podcast) {
                self.podcasts.remove(at: index)
                UserDefaults.standard.set(self.podcasts.serialized, forKey: self.favoritePodcastKey)
                self.subscribers.fire(.removed(podcast, self.podcasts))
            }
        }
    }
    
    func subscribe(_ subscriber: @escaping (FavoritePodcastsStorageEvent) -> Void) -> Subscription {
        subscriber(.initial(podcasts))
        return subscribers.subscribe(action: subscriber)
    }
}

private extension Array where Element == Podcast {
    var serialized: Data {
        return try! JSONEncoder().encode(self)
    }
    static func deserialize(from data: Data) -> Self {
        return try! JSONDecoder().decode(self, from: data)
    }
}

extension UserDefaults {
    func extract<T: Decodable>(withKey key: String) -> T? {
        if let serializedObject = value(forKey: key) as? Data {
            return try? JSONDecoder().decode(T.self, from: serializedObject)
        }
        return nil
    }
}
