//
//  FavoritesPodcastCell.swift
//  Podcasts
//
//  Created by Олег Черных on 18/05/2020.
//  Copyright © 2020 Олег Черных. All rights reserved.
//

import UIKit
import PromiseKit

final class FavoritesPodcastCell: UICollectionViewCell {
    var podcast: Podcast! {
        didSet {
            updateViewWithModel()
        }
    }
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let artistNameLabel = UILabel()
    private let loadingImageIndicator = UIActivityIndicatorView()
    
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
    
    private var timer: Timer?
    private func updateViewWithModel() {
        artistNameLabel.text = podcast.artistName ?? ""
        nameLabel.text = podcast.name ?? ""
        if let imageUrl = podcast.imageUrl {
            if !loadingImageIndicator.isAnimating {
                loadingImageIndicator.startAnimating()
            }
            
            timer?.invalidate()
//            timer = Timer(timeInterval: 1.0, repeats: false) { [weak self] _ in
//                guard let self = self else { return }
//                
//                firstly {
//                    EpisodeCell.imageFetcher.fetchImage(withImageUrl: imageUrl)
//                }.done(on: .main, flags: nil) { (image) in
//                    if let actualUrl = self.podcast.imageUrl, imageUrl == actualUrl {
//                        self.imageView.image = image
//                    }
//                }.ensure(on: .main, flags: nil) {
//                    self.loadingImageIndicator.stopAnimating()
//                }.catch(on: .main, flags: nil, policy: .allErrors) { _ in }
//            }
            timer?.tolerance = 0.2
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stylizeUI()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        loadingImageIndicator.center = .init(x: bounds.width / 2, y: bounds.width / 2)
    }
}
