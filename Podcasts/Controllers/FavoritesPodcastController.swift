//
//  FavoritesController.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Combine

final class FavoritePodcastsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, FavoritePodcastCellViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, FavoritePodcastCellViewModel>
    enum Section {
        case main
    }
    private static let cellId = "favoritePodcastCell"
    private let sideInset: CGFloat = 16
    private let spacingBetweenItems: CGFloat = 16
    private var subscriptions: Set<AnyCancellable> = []
    private lazy var dataSource = makeDataSource()
    // MARK: - dependencies
    var viewModel: FavoritePodcastsViewModel!
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBindings()
        viewModel.viewBecomeVisible()
    }
    // MARK: - setup
    private lazy var setupBindings: () -> Void = { [unowned self] in
        executeOnce {
            [
                self.viewModel.$badgeText
                    .receive(on: DispatchQueue.main)
                    .sink { self.navigationController?.tabBarItem.badgeValue = $0 },
                self.viewModel.$favoritePodcastCellViewModels
                    .receive(on: DispatchQueue.main)
                    .sink {
                        var snapshot = Snapshot()
                        snapshot.appendSections([.main])
                        snapshot.appendItems($0, toSection: .main)
                        self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
                    }
            ].store(in: &self.subscriptions)
        }
    }()
    
    private func setupCollectionView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGestureHappened(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: false)
        collectionView.backgroundColor = .white
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastsController.cellId)
        collectionView.dataSource = dataSource
    }
    // MARK: - helpers
    private func makeDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, viewModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoritePodcastsController.cellId,
                for: indexPath
            ) as! FavoritePodcastCell
            cell.viewModel = viewModel
            return cell
        }
    }
    // MARK: - interaction handlers
    @objc
    private func onLongPressGestureHappened(_ gesture: UILongPressGestureRecognizer) {
        let gestureLocation = gesture.location(in: collectionView)
        if
            let indexPath = collectionView.indexPathForItem(at: gestureLocation),
            let cell = collectionView.cellForItem(at: indexPath) as? FavoritePodcastCell
        {
            let podcast = cell.viewModel.podcast
            let alertController = UIAlertController(
                title: "Delete \(podcast.name ?? "") podcast from favorites?",
                message: nil,
                preferredStyle: .actionSheet
            )
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.viewModel.removePodcastFromFavorites(podcast)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    // MARK: - UICollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.snapshot().numberOfItems
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
        if let podcast = dataSource.itemIdentifier(for: indexPath)?.podcast {
            let model = EpisodesModel(
                podcast: podcast,
                podcastStorage: ServiceLocator.favoritePodcastsStorage,
                episodeFetcher: ServiceLocator.podcastService,
                trackListPlayer: Player.shared
            )
            let viewModel = EpisodesViewModel(model: model)
            let controller = EpisodesController()
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
