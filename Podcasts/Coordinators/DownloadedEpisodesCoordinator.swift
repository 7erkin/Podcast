//
//  DownloadedEpisodesCoordinator.swift
//  Podcasts
//
//  Created by user166334 on 5/26/20.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Foundation

final class DownloadedEpisodesCoordintator: Coordinatable {
    var child: Coordinatable!
    var navigationController: UINavigationController!
    
    init(withNavigationController navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let model = DownloadedEpisodesModel(recordsManager: ServiceLocator.recordsManager, player: Player.shared)
        let downloadedEpisodesController = DownloadedEpisodesController()
        downloadedEpisodesController.model = model
        downloadedEpisodesController.navigationItem.title = "Downloads"
        navigationController.pushViewController(downloadedEpisodesController, animated: true)
    }
}
