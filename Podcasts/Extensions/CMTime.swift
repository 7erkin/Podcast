//
//  CMTime.swift
//  Podcasts
//
//  Created by Олег Черных on 09/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import AVKit

extension CMTime {
    var convertable: Bool {
        return !(self.seconds.isNaN || self.seconds.isInfinite)
    }
    var roundedSeconds: TimeInterval {
        return self.seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
}
