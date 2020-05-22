//
//  Array.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

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
