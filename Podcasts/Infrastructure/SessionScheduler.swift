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
// must work on main thread
final class SessionScheduler {
    private var backgroundTaskId: UIBackgroundTaskIdentifier?
    private var clients: [URLSessionSchedulable] = []
    private var subscriptions: Set<AnyCancellable> = []
    private var isClientsScheduledToBackground = true
    init() {
        let center = NotificationCenter.default
        center
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .filter { _ in self.isClientsScheduledToBackground }
            .sink { [weak self] _ in self?.scheduleClientsToForeground() }
            .store(in: &subscriptions)
        
        center
            .publisher(for: UIApplication.willTerminateNotification)
            .filter { _ in !self.isClientsScheduledToBackground }
            .sink { [weak self] _ in self?.scheduleClientsToBackground() }
            .store(in: &subscriptions)
    }
    
    func register(client: URLSessionSchedulable) {
        if clients.isEmpty {
            clients.append(client)
            backgroundTaskId = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.scheduleClientsToBackground()
                if let taskId = self?.backgroundTaskId {
                    UIApplication.shared.endBackgroundTask(taskId)
                }
            }
        } else {
            if !clients.contains(where: { $0.sessionId == client.sessionId }) {
                clients.append(client)
            }
        }
    }
    
    func remove(client: URLSessionSchedulable) {
        if let index = clients.firstIndex(where: { $0.sessionId == client.sessionId }) {
            clients.remove(at: index)
            if clients.isEmpty, let taskId = backgroundTaskId {
                UIApplication.shared.endBackgroundTask(taskId)
            }
        }
    }
    
    private func scheduleClientsToBackground() {
        clients.forEach { $0.transitToBackgroundSessionExecution() }
        isClientsScheduledToBackground = true
    }
    
    private func scheduleClientsToForeground() {
        clients.forEach { $0.transitToForegroundSessionExecution() }
        isClientsScheduledToBackground = false
    }
}
