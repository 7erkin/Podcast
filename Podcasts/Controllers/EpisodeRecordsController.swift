//
//  DownloadedEpisodeRecordsController.swift
//  Podcasts
//
//  Created by Олег Черных on 20/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import Foundation
import UIKit

protocol EpisodeRecordsControllerCoordinatorDelegate: class {
    func choose(episode: Episode)
}

class EpisodeRecordsController: UICollectionViewController {
    fileprivate let cellId = "cellId"
    weak var coordinator: EpisodeRecordsControllerCoordinatorDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
    }
}
