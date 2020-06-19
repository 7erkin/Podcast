//
//  FavoritesPodcastViewModel.swift
//  Podcasts
//
//  Created by Олег Черных on 17/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine

final class FavoritePodcastsViewModel: ObservableObject {
    @Published var badgeText: String?
    @Published var favoritePodcasts: [FavoritePodcastCellViewModel] = []
    private var model: FavoritePodcastsModel
    private var subscriptions: [Subscription] = []
    init(_ model: FavoritePodcastsModel) {
        self.model = model
        model
            .subscribe { [unowned self] in self.updateWithModel($0) }
            .stored(in: &subscriptions)
    }
    
    func removePodcastFromFavorites(_ podcast: Podcast) {
//        if let index = favoritePodcasts.firstIndex(where: { $0 == podcast }) {
//            model.removeFromFavorites(podcastIndex: index)
//        }
    }
    
    private func updateWithModel(_ event: FavoritePodcastsModelEvent) {}
}
