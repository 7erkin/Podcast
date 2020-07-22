//
//  Logger.swift
//  Podcasts
//
//  Created by Олег Черных on 19.07.2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import os

class Logger {
    static let subsystem = "com.nighttrain18.PodcastsLogger"
    static let urlSesssionLogger = URLSessionLogger()
}

final class URLSessionLogger {
    private let category = "URLSessionLogger"
    private let logger: OSLog
    init() {
        logger = .init(subsystem: Logger.subsystem, category: category)
    }
    
    func log(_ message: StaticString) {
        os_log(message, log: logger, type: .debug)
    }
}

