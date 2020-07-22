//
//  DefferedBlock.swift
//  Podcasts
//
//  Created by Олег Черных on 24/06/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation

final class DefferedBlock {
    private var timer: Timer?
    init(timeInterval: TimeInterval, executeOn queue: DispatchQueue, _ block: @escaping () -> Void) {
        timer = Timer(timeInterval: timeInterval, repeats: false) { _ in queue.async { block() } }
        timer?.tolerance = 0.2
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    deinit {
        timer?.invalidate()
    }
}
