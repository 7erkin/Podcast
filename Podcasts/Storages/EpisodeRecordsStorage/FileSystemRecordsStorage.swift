//
//  SQLEpisodeRecordStoraging.swift
//  Podcasts
//
//  Created by Олег Черных on 21/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

// saved episode stored as directory where json { StoredItem } and recordsFile.
// directory name is awCollectionId=510318&awEpisodeId=857652287 (number1.number2)
class FileSystemRecordsStorage: EpisodeRecordsStoraging {
    private let serviceQueue = DispatchQueue(
        label: "file.system.records.storage",
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
    static var shared: FileSystemRecordsStorage? = FileSystemRecordsStorage()
    private init?() {
        if let isExist = try? isRecordsDirectoryExist().wait() {
            if !isExist {
                try! createRecordsRootDirectory().wait()
            }
        } else {
            return nil
        }
    }
    
    func save(episode: Episode, ofPodcast podcast: Podcast, withRecord record: Data) -> Promise<Void> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<Void> in
            // create record directory
            let directoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(directoryName)
            try! FileManager.default.createDirectory(at: directoryUrl.absoluteURL, withIntermediateDirectories: true, attributes: nil)
            // create record file in directory
            var recordUrl = directoryUrl
            recordUrl.appendPathComponent("record")
            try! record.write(to: recordUrl)
            //precondition(FileManager.default.createFile(atPath: recordUrl.absoluteString, contents: record, attributes: nil))
            // create description file in record directory
            var itemDesriptionUrl = directoryUrl
            itemDesriptionUrl.appendPathComponent("description")
            let itemDescription = StoredEpisodeRecordItem(episode: episode, podcast: podcast, recordUrl: recordUrl)
            let serializedItemDescription = try! JSONEncoder().encode(itemDescription)
            try! serializedItemDescription.write(to: itemDesriptionUrl)
            //precondition(FileManager.default.createFile(atPath: itemDesriptionUrl.absoluteString, contents: serializedItemDescription, attributes: nil))
            return Promise.value
        }
    }
    
    func delete(episode: Episode) -> Promise<Void> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<Void> in
            let deletedDirectoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(deletedDirectoryName)
            try? FileManager.default.removeItem(at: directoryUrl)
            return Promise.value
        }
    }
    
    func getStoredEpisodeRecordItem(_ episode: Episode) -> Promise<StoredEpisodeRecordItem> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<StoredEpisodeRecordItem> in
            let directoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
            var descriptionUrl = self.recordsDirectoryRootUrl
            descriptionUrl.appendPathComponent(directoryName)
            descriptionUrl.appendPathComponent("description")
            let serializedItemDescription = FileManager.default.contents(atPath: descriptionUrl.absoluteString)!
            let item = try! JSONDecoder().decode(StoredEpisodeRecordItem.self, from: serializedItemDescription)
            return Promise { resolver in resolver.fulfill(item) }
        }
    }
    
    func getStoredEpisodeRecordList() -> Promise<[StoredEpisodeRecordItem]> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<[StoredEpisodeRecordItem]> in
            let items = try! FileManager.default.contentsOfDirectory(
                at: self.recordsDirectoryRootUrl,
                includingPropertiesForKeys: nil,
                options: []
            ).compactMap { recordDirectoryUrl -> Data? in
                var itemDescriptionUrl = recordDirectoryUrl
                itemDescriptionUrl.appendPathComponent("description")
                //let fd = try? FileHandle(forReadingFrom: itemDescriptionUrl)
                //let serializedItemDescription = FileManager.default.contents(atPath: itemDescriptionUrl.absoluteString)
                return try? FileHandle(forReadingFrom: itemDescriptionUrl).readDataToEndOfFile()
            }.map { data in
                return try! JSONDecoder().decode(StoredEpisodeRecordItem.self, from: data)
            }
            return Promise { resolver in resolver.fulfill(items) }
        }
    }
    
    func hasEpisode(_ episode: Episode) -> Promise<Bool> {
        return Promise.value.then(on: serviceQueue, flags: nil) { _ -> Promise<Bool> in
            let directoryName = self.getRecordDirectoryName(forSavedEpisode: episode)
            var directoryUrl = self.recordsDirectoryRootUrl
            directoryUrl.appendPathComponent(directoryName)
            let isExist = FileManager.default.fileExists(atPath: directoryUrl.absoluteString)
            return Promise { resolver in resolver.fulfill(isExist) }
        }
    }
    
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
