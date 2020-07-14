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
import Combine

final class URLSessionScheduler {
    typealias ResignSchedulerClient = () -> Void
    private var schedulerClients: [String:URLSessionSchedulable] = [:]
    private var isSessionsMoveToBackground = false
    private var subscription: AnyCancellable?
    init() {
        subscription = NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .filter { _ in self.isSessionsMoveToBackground }
            .sink { [weak self] _ in
                print("Active!")
                self?.schedulerClients.values.forEach { $0.foregroundTransit() }
                self?.isSessionsMoveToBackground = false
            }
    }
    
    func becomeSchedulerClient(_ schedulerClient: URLSessionSchedulable) -> Promise<ResignSchedulerClient> {
        return Promise { resolver in
            DispatchQueue.main.async { [weak self] in
                guard self?.schedulerClients[schedulerClient.sessionId] == nil else {
                    fatalError("Such client has already registered")
                }
                
                self?.schedulerClients[schedulerClient.sessionId] = schedulerClient
                let taskId = UIApplication.shared.beginBackgroundTask {
                    DispatchQueue.main.async { [weak self] in
                        self?.isSessionsMoveToBackground = true
                        schedulerClient.backgroundTransit()
                    }
                }
                let canceller = {
                    UIApplication.shared.endBackgroundTask(taskId)
                    self?.schedulerClients.removeValue(forKey: schedulerClient.sessionId)
                }
                resolver.fulfill(canceller)
            }
        }
    }
    
    func triggerBackgroundSessionEventHandling(sessionIdentifier: String, _ completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?.schedulerClients[sessionIdentifier]?.handleSessionEvent(completionHandler)
        }
    }
    
    func isSchedulerClient(_ client: URLSessionSchedulable) -> Promise<Bool> {
        return Promise { resolver in
            DispatchQueue.main.async { [weak self] in
                if let clients = self?.schedulerClients {
                    resolver.fulfill(clients[client.sessionId] != nil)
                } else {
                    resolver.fulfill(false)
                }
            }
        }
    }
}
