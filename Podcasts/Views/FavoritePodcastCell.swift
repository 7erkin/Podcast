//
//  FavoritesPodcastCell.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import Combine

final class FavoritePodcastCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let loadingImageIndicator = UIActivityIndicatorView()
    private var imageSubscription: AnyCancellable?
    var viewModel: FavoritePodcastCellViewModel! {
        didSet {
            if self.viewModel != nil {
                artistNameLabel.text = self.viewModel.artistName
                nameLabel.text = self.viewModel.podcastName
                loadingImageIndicator.startAnimating()
            }
        }
    }
    
    private func stylizeUI() {
        nameLabel.text = "Podcast name"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        artistNameLabel.text = "Artist name"
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.textColor = .lightGray
    }
    
    private func setupView() {
        imageView.backgroundColor = .systemGroupedBackground
        imageView.contentMode = .scaleAspectFill
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        loadingImageIndicator.hidesWhenStopped = true
        addSubview(loadingImageIndicator)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        viewModel = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stylizeUI()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateImage() {
        let imageSize = imageView.frame.size
        imageSubscription?.cancel()
        imageSubscription = viewModel.podcastImagePublisher
//            .receive(on: DispatchQueue.global(qos: .userInitiated))
//            .map { downsample(imageData: $0, to: imageSize, scale: UITraitCollection.current.displayScale) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    self.imageView.image = UIImage(data: $0)!
                    self.loadingImageIndicator.stopAnimating()
                }
            )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        loadingImageIndicator.center = .init(x: bounds.width / 2, y: bounds.width / 2)
        updateImage()
    }
}
