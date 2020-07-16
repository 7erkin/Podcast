//
//  RecordDownloader+URLSessionSchedulable.swift
//  Podcasts
//
//  Created by user166334 on 7/16/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

extension RecordDownloader: URLSessionSchedulable {
    var sessionId: String { backgroundSessionIdentifier }
    
    func backgroundTransit() {
        print(#function)
    }
    
    func foregroundTransit() {
        print(#function)
    }
    
    func handleSessionEvent(_ completionHandler: @escaping () -> Void) {
        print(#function)
    }
}
