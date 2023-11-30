//
//  VideoViewController.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    let viewModel = VideoViewModel()
    
    var visibleIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.viewModel.getVideos()
        self.setupCollectionView()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .black
        self.collectionView.backgroundColor = .black
        
        self.view.addSubview(collectionView)
        
        self.setupContraints()
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "videoCell")
    }
}

extension VideoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! VideoCollectionViewCell
        
        cell.delegate = self
        cell.setupPlayer(video: self.viewModel.videos[indexPath.item])
        
        if indexPath == self.visibleIndexPath {
            cell.play()
        } else {
            cell.resetPlayer()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            if cell.player?.rate == 0 {
                cell.play()
            } else {
                cell.pause()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
}

extension VideoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let indexPath = visibleIndexPath,
           let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            cell.pause()
        }
        
        let center = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                             y: collectionView.center.y + collectionView.contentOffset.y)
        
        if let indexPath = collectionView.indexPathForItem(at: center) {
            self.visibleIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
                cell.play()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let center = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                             y: collectionView.center.y + collectionView.contentOffset.y)
        
        if let indexPath = collectionView.indexPathForItem(at: center) {
            visibleIndexPath = indexPath
            
            for (index, _) in self.viewModel.videos.enumerated() {
                if index != indexPath.item {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCollectionViewCell {
                        cell.resetPlayer()
                    }
                }
            }
        }
    }
}

extension VideoViewController: VideocCollectionViewCellDelegate {
    func setupImageFromData(in cell: VideoCollectionViewCell, url: URL) {
        self.viewModel.loadImageFromURL(url: url) { data in
            cell.configureUserImage(data: data)
        }
    }
    
    func increaseReactionOfVideo(in cell: VideoCollectionViewCell, tag: Int) {
        if let indexPath = self.collectionView.indexPath(for: cell) {
            self.viewModel.increaseHeartOrFireCount(tag: tag, video: self.viewModel.videos[indexPath.item])
            cell.updateCountLabels(video: self.viewModel.videos[indexPath.item])
        }
    }
}
