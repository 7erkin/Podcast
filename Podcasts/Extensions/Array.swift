//
//  Array.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Combine

extension Array {
    var lastIndex: Int? {
        return self.isEmpty ? nil : self.count - 1
    }
}

extension Array where Element == Episode {
    func applyPodcastImageIfNeeded(_ podcast: Podcast) -> [Episode] {
        return self.map { episode -> Episode in
            if let _ = episode.imageUrl { return episode }
            
            var copy = episode
            copy.imageUrl = podcast.imageUrl
            return copy
        }
    }
}

extension Array where Element == AnyCancellable {
    func store(in storage: inout Set<AnyCancellable>) {
        self.forEach { $0.store(in: &storage) }
    }
}
