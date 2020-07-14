//
//  SQLEpisodeRecordStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//
import Foundation
import PromiseKit

// directory name is awCollectionId=510318&awEpisodeId=857652287 (number1.number2)
final class FileSystemRecordsStorage: EpisodeRecordStoraging {
    struct UrlForRecordSave {
        let rootUrl: URL
        let recordUrl: URL
        let recordDescriptorUrl: URL
    }
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
        do {
            try createRecordDirectoryIfNeeded()
        } catch { return nil }
    }
    // MARK: - EpisodeRecordStoraging
    func saveRecord(_ recordData: Data, ofEpisode episode: Episode, ofPodcast podcast: Podcast) -> Promise<[EpisodeRecordDescriptor]> {
        return saveRecord(ofEpisode: episode, ofPodcast: podcast, saveBlock: { try recordData.write(to: $0) })
    }
    
    func saveRecord(withUrl url: URL, ofEpisode episode: Episode, ofPodcast podcast: Podcast) -> Promise<[EpisodeRecordDescriptor]> {
        return saveRecord(ofEpisode: episode, ofPodcast: podcast, saveBlock: { try FileManager.default.moveItem(at: url, to: $0) })
    }
    
    func removeRecord(_ recordDescriptor: EpisodeRecordDescriptor) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            let deletedDirectoryName = self.getRecordDirectoryName(forSavedEpisode: recordDescriptor.episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(deletedDirectoryName)
            do {
                try FileManager.default.removeItem(at: directoryUrl)
                return self.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
            } catch {
                throw EpisodeRecordStorageError.removeRecordError(recordDescriptor)
            }
        }
    }
    
    func getEpisodeRecordDescriptors(
        withSortPolicy sortPolicy: @escaping (EpisodeRecordDescriptor, EpisodeRecordDescriptor) -> Bool
    ) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            let recordDescriptors = try? FileManager.default.contentsOfDirectory(
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
            
            if let descriptors = recordDescriptors {
                return Promise { resolver in resolver.fulfill(descriptors) }
            }
            
            throw EpisodeRecordStorageError.loadingRecordsError
        }
    }
    // MARK: - helpers
    private func getUrlForRecordSave(forSavedEpisode episode: Episode) -> UrlForRecordSave {
        let directoryName = getRecordDirectoryName(forSavedEpisode: episode)
        let directoryUrl = recordsDirectoryRootUrl.appendingPathComponent(directoryName)
        return UrlForRecordSave(
            rootUrl: directoryUrl,
            recordUrl: directoryUrl.appendingPathComponent(recordFileName),
            recordDescriptorUrl: directoryUrl.appendingPathComponent(recordDescriptionFileName)
        )
    }
    
    private func saveRecord(
        ofEpisode episode: Episode,
        ofPodcast podcast: Podcast,
        saveBlock: @escaping (URL) throws -> Void
    ) -> Promise<[EpisodeRecordDescriptor]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[EpisodeRecordDescriptor]> in
            let url = self.getUrlForRecordSave(forSavedEpisode: episode)
            let fileManager = FileManager.default
            do {
                // create record directory
                try fileManager.createDirectory(at: url.rootUrl.absoluteURL, withIntermediateDirectories: true, attributes: nil)
                // create record file in directory
                try saveBlock(url.recordUrl)
                // create description file in record directory
                let recordDescriptor = EpisodeRecordDescriptor(episode: episode, podcast: podcast, recordUrl: url.recordUrl)
                let serializedRecordDescription = try JSONEncoder().encode(recordDescriptor)
                try serializedRecordDescription.write(to: url.recordDescriptorUrl)
                return self.getEpisodeRecordDescriptors(withSortPolicy: { $0.dateOfCreate > $1.dateOfCreate })
            } catch let err {
                print("Error again: ", err)
                [url.recordUrl, url.recordDescriptorUrl].forEach { try? fileManager.removeItem(at: $0) }
                throw EpisodeRecordStorageError.saveRecordError(episode, podcast)
            }
        }
    }
    
    private func createRecordDirectoryIfNeeded() throws {
        if try isRecordsDirectoryExist().wait() {
            try createRecordsRootDirectory().wait()
        }
    }
    
    private func createRecordsRootDirectory() -> Promise<Void> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ throws -> Promise<Void> in
            try FileManager.default.createDirectory(at: self.recordsDirectoryRootUrl, withIntermediateDirectories: true, attributes: [:])
            return Promise.value
        }
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
