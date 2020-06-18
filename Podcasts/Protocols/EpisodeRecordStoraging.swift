//
//  EpisodeRecordStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 11/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import PromiseKit
import Foundation

protocol EpisodeRecordStoraging: class {
    func saveRecord(_ recordData: Data, ofEpisode episode: Episode, ofPodcast podcast: Podcast) -> Promise<[EpisodeRecordDescriptor]>
    func removeRecord(_ recordDescriptor: EpisodeRecordDescriptor) -> Promise<[EpisodeRecordDescriptor]>
    func getEpisodeRecordDescriptors(
        withSortPolicy sortPolicy: @escaping (EpisodeRecordDescriptor, EpisodeRecordDescriptor) -> Bool
    ) -> Promise<[EpisodeRecordDescriptor]>
}
 
