//
//  BackgroundSessionScheduler.swift
//  Podcasts
//
//  Created by user166334 on 7/14/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

final class BackgroundSessionScheduler {
    typealias RegistrationCanceller = () -> Void
    private var clients: [String:BackgroundSessionSchedulable] = [:]
    func register(_ client: BackgroundSessionSchedulable) -> Promise<RegistrationCanceller> {
        return Promise { resolver in
            DispatchQueue.main.async { [weak self] in
                guard self?.clients[client.sessionId] == nil else { fatalError("") }
                
                self?.clients[client.sessionId] = client
                let taskId = UIApplication.shared.beginBackgroundTask { client.backgroundTransit() }
                let canceller = {
                    UIApplication.shared.endBackgroundTask(taskId)
                    self?.clients.removeValue(forKey: client.sessionId)
                }
                resolver.fulfill(canceller)
            }
        }
    }
    
    func applicationDidBecomeForeground() {
        DispatchQueue.main.async { [weak self] in
            self?.clients.values.forEach { $0.foregroundTransit() }
        }
    }
    
    func handleBackgroundSessionEvent(sessionIdentifier: String, _ completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.clients[sessionIdentifier]?.handleSessionEvent(completionHandler)
        }
    }
}
