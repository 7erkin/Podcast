//
//  FavoritesController.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit

protocol FavoritesPodcastControllerCoordinatorDelegate: class {
    func choose(podcast: Podcast)
}

class FavoritesPodcastController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    fileprivate let cellId = "cellId"
    fileprivate let sideInset: CGFloat = 16
    fileprivate let spacingBetweenItems: CGFloat = 16
    // MARK: - dependencies
    weak var coordinator: FavoritesPodcastControllerCoordinatorDelegate!
    var favoritePodcastsModel: FavoritePodcastsModel! {
        didSet {
            self.favoritePodcastsModel.initialize()
            self.favoritePodcastsModel.subscriber = { [weak self] in
                self?.updateViewWithModel(withEvent: $0)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.tabBarItem.badgeValue = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureHappened(_:)))
        longPressGesture.minimumPressDuration = 1.5
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.backgroundColor = .white
        collectionView.register(FavoritesPodcastCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    fileprivate func updateViewWithModel(withEvent event: FavoritePodcastsModel.Event) {
        switch event {
        case .initialized:
            collectionView.reloadData()
        case .podcastSaved:
            collectionView.reloadData()
            navigationController?.tabBarItem.badgeValue = "NEW"
        case .podcastDeleted:
            collectionView.reloadData()
        }
    }
    
    @objc
    fileprivate func onLongPressGestureHappened(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: gestureLocation) {
            let podcastIndex = indexPath.row
            let podcast = favoritePodcastsModel.podcasts[podcastIndex]
            let alertController = UIAlertController(title: "Delete \(podcast.name ?? "") podcast from favorites?", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.favoritePodcastsModel.deletePodcast(podcastIndex: podcastIndex)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritePodcastsModel.podcasts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavoritesPodcastCell
        // if this safe code??? what if podcasts changed in model?
        cell.podcast = favoritePodcastsModel.podcasts[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.bounds.width - (2 * sideInset + spacingBetweenItems)) / 2
        return CGSize(width: itemWidth, height: itemWidth + 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenItems
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sideInset, left: sideInset, bottom: sideInset, right: sideInset)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let podcast = favoritePodcastsModel.podcasts[indexPath.row]
        coordinator.choose(podcast: podcast)
    }
}
