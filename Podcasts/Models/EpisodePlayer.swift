//
//  EpisodePlayer.swift
//  Podcasts
//
//  Created by Олег Черных on 07/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import AVKit

struct EpisodePlayer {
    var timePast: CMTime
    var duration: CMTime
    var volumeLevel: Int
    var isPlaying: Bool
}
