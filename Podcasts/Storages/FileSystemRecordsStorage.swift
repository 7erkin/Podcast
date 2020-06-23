//
//  SQLEpisodeRecordStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//
import Foundation
import PromiseKit

// saved episode stored as directory where json { StoredItem } and recordsFile.
// directory name is awCollectionId=510318&awEpisodeId=857652287 (number1.number2)
final class FileSystemRecordsStorage: EpisodeRecordStoraging {
    private let recordDescriptionFileName = "description"
    private let recordFileName = "record.mp3"
    private let serviceQueue = DispatchQueue(
        label: "episode.records.storage",
        qos: .userInitiated,
        attributes: .concurrent,
        autoreleaseFrequency: .workItem,
        target: nil
    )
    private let recordsDirectoryRootUrl: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var url = paths[0]
        url.appendPathComponent("Records")
        return url
    }()
    init?() {
        if let isExist = try? isRecordsDirectoryExist().wait() {
            if !isExist {
                try! createRecordsRootDirectory().wait()
            }
        } else {
            return nil
        }
    }
    // MARK: - EpisodeRecordStoraging
    func saveRecord(_ recordData: Data, ofEpisode episode: Episode, ofPodcast podcast: Podcast) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            // create record directory
            let directoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(directoryName)
            try! FileManager.default.createDirectory(at: directoryUrl.absoluteURL, withIntermediateDirectories: true, attributes: nil)
            // create record file in directory
            var recordUrl = directoryUrl
            recordUrl.appendPathComponent(self.recordFileName)
            try! recordData.write(to: recordUrl)
            // create description file in record directory
            var recordDescriptorUrl = directoryUrl
            recordDescriptorUrl.appendPathComponent(self.recordDescriptionFileName)
            let recordDescriptor = EpisodeRecordDescriptor(episode: episode, podcast: podcast, recordUrl: recordUrl)
            let serializedRecordDescription = try! JSONEncoder().encode(recordDescriptor)
            try! serializedRecordDescription.write(to: recordDescriptorUrl)
            return self.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
        }
    }
    
    func removeRecord(_ recordDescriptor: EpisodeRecordDescriptor) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            let deletedDirectoryName = self.getRecordDirectoryName(forSavedEpisode: recordDescriptor.episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(deletedDirectoryName)
            try? FileManager.default.removeItem(at: directoryUrl)
            return self.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
        }
    }
    
    func getEpisodeRecordDescriptors(
        withSortPolicy sortPolicy: @escaping (EpisodeRecordDescriptor, EpisodeRecordDescriptor) -> Bool
    ) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            let recordDescriptors = try! FileManager.default.contentsOfDirectory(
                at: self.recordsDirectoryRootUrl,
                includingPropertiesForKeys: nil,
                options: []
            ).compactMap { recordDirectoryUrl -> Data? in
                var url = recordDirectoryUrl
                url.appendPathComponent(self.recordDescriptionFileName)
                return try? FileHandle(forReadingFrom: url).readDataToEndOfFile()
            }.compactMap { data in
                return try? JSONDecoder().decode(EpisodeRecordDescriptor.self, from: data)
            }.sorted(by: sortPolicy)
            return Promise { resolver in resolver.fulfill(recordDescriptors) }
        }
    }
    // MARK: - helpers
    private func createRecordsRootDirectory() -> Promise<Void> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<Void> in
            try! FileManager.default.createDirectory(at: self.recordsDirectoryRootUrl, withIntermediateDirectories: true, attributes: [:])
            return Promise.value
        }
    }
    
    private func createRecordDirectory(forEpisode episode: Episode) {
        let directoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
        var directoryUrl = self.recordsDirectoryRootUrl
        directoryUrl.appendPathComponent(directoryName)
        try! FileManager.default.createDirectory(atPath: directoryUrl.absoluteString, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func isRecordsDirectoryExist() -> Promise<Bool> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<Bool> in
            let isExist = FileManager.default.fileExists(atPath: self.recordsDirectoryRootUrl.absoluteString)
            return Promise { resolver in resolver.fulfill(isExist) }
        }
    }
    // must be refactored
    private func getRecordDirectoryName(forSavedEpisode episode: Episode) -> String {
        let streamUrl = episode.streamUrl
        if let components = URLComponents(url: streamUrl, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                let collectionIdIndex = queryItems.firstIndex(where: { $0.name == "awCollectionId" })!
                let episodeIdIndex = queryItems.firstIndex(where: { $0.name == "awEpisodeId" })!
                let collectionId = queryItems[collectionIdIndex].value!
                let episodeId = queryItems[episodeIdIndex].value!
                return "\(collectionId).\(episodeId)"
            }
        }
        fatalError("UB")
    }
}
