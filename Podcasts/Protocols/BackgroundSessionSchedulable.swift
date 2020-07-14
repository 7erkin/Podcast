//
//  BackgroundSessionSchedulable.swift
//  Podcasts
//
//  Created by user166334 on 7/14/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

protocol BackgroundSessionSchedulable: class {
    var sessionId: String { get }
    func backgroundTransit()
    func foregroundTransit()
    func handleSessionEvent(_ completionHandler: @escaping () -> Void)
}
