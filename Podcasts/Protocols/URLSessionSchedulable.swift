//
//  BackgroundSessionSchedulable.swift
//  Podcasts
//
//  Created by user166334 on 7/14/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

protocol URLSessionSchedulable: class {
    var sessionId: String { get }
    func transitToBackgroundSessionExecution()
    func transitToForegroundSessionExecution()
}
