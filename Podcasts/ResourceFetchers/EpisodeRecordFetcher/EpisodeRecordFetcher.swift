//
//  EpisodeRecordFetcher.swift
//  Podcasts
//
//  Created by Олег Черных on 23/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

struct EpisodeRecordFetcherError: Error {}

final class EpisodeRecordFetcher: EpisodeRecordFetching {
    func fetch(episode: Episode, _ progressHandler: ((Double) -> Void)?) -> Promise<Data> {
        return  Promise { resolver in
            let downloadRequest = AF.download(episode.streamUrl)
            downloadRequest.downloadProgress { progress in
                progressHandler?(progress.fractionCompleted)
            }
            downloadRequest.responseData { dataResponse in
                if let _ = dataResponse.error {
                    resolver.reject(EpisodeRecordFetcherError())
                    return
                }
                
                guard let data = dataResponse.value else {
                    resolver.reject(EpisodeRecordFetcherError())
                    return 
                }
                
                resolver.fulfill(data)
            }
        }
    }
}
