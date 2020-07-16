//
//  NetworkReachability.swift
//  Podcasts
//
//  Created by user166334 on 7/16/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import Combine
import Reachability

enum NetworkReachabilityEvent {
    case notReachable
    case reachable
}

final class NetworkReachability {
    @Published var publisher: NetworkReachabilityEvent = .reachable
    private var reachability: Reachability?
    private var subscription: AnyCancellable?
    init?() {
        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
            subscription = NotificationCenter
                .default
                .publisher(for: .reachabilityChanged)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] notification in
                    if let reachability = notification.object as? Reachability {
                        switch reachability.connection {
                        case .cellular:
                            fallthrough
                        case .wifi:
                            self?.publisher = .reachable
                        case .unavailable:
                            self?.publisher = .notReachable
                        case .none:
                            self?.publisher = .notReachable
                        }
                    }
                }
        } catch {
            return nil
        }
    }
    
    deinit {
        reachability?.stopNotifier()
    }
}
