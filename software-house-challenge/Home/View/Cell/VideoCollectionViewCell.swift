//
//  VideoCollectionViewCell.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import AVFoundation
import AVKit
import UIKit

protocol VideocCollectionViewCellDelegate: AnyObject {
    func setupImageFromData(in cell: VideoCollectionViewCell, url: URL)
    func increaseReactionOfVideo(in cell: VideoCollectionViewCell, tag: Int)
}

class VideoCollectionViewCell: UICollectionViewCell {
    
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var heartIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.circle"))
        imageView.tintColor = .red
        imageView.tag = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var heartCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fireIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "flame.circle"))
        imageView.tintColor = .orange
        imageView.tag = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var fireCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var swipeLeftGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        gesture.direction = .left
        return gesture
    }()
    
    private lazy var swipeRightGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        gesture.direction = .right
        return gesture
    }()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    private var heartCount = 0
    private var fireCount = 0
    
    var video: Video!
    
    weak var delegate: VideocCollectionViewCellDelegate?
    
    @objc private func swipeLeft() {
        self.performSwipeAnimation(translation: -bounds.width * 0.2)
        self.delegate?.increaseReactionOfVideo(in: self, tag: self.fireIconImageView.tag)
    }
    
    @objc private func swipeRight() {
        self.performSwipeAnimation(translation: bounds.width * 0.2)
        self.delegate?.increaseReactionOfVideo(in: self, tag: self.heartIconImageView.tag)
    }
    
    @objc private func handleHeartTap() {
        self.delegate?.increaseReactionOfVideo(in: self, tag: self.heartIconImageView.tag)
    }
    
    @objc private func handleFireTap() {
        self.delegate?.increaseReactionOfVideo(in: self, tag: self.fireIconImageView.tag)
    }
    
    func configureUserImage(data: Data) {
        DispatchQueue.main.async {
            self.userImageView.image = UIImage(data: data)
        }
    }
    
    func updateCountLabels(video: Video) {
        self.video = video
        self.heartCountLabel.text = String(self.video.heartCount)
        self.fireCountLabel.text = String(self.video.fireCount)
    }
    
    private func performSwipeAnimation(translation: CGFloat) {
        let maxIconTranslation: CGFloat = 80
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: translation, y: 0)
            
            let leftIconTranslation = min(max(0, translation), maxIconTranslation)
            self.heartIconImageView.transform = CGAffineTransform(translationX: -leftIconTranslation, y: 0)
            
            let rightIconTranslation = min(max(0, -translation), maxIconTranslation)
            self.fireIconImageView.transform = CGAffineTransform(translationX: rightIconTranslation, y: 0)
        }) { (_) in
            self.resetPosition()
        }
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
            self.heartIconImageView.transform = .identity
            self.fireIconImageView.transform = .identity
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addGestures() {
        self.addGestureRecognizer(self.swipeLeftGesture)
        self.addGestureRecognizer(self.swipeRightGesture)
        
        let heartTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeartTap))
        self.heartIconImageView.addGestureRecognizer(heartTapGesture)
        self.heartIconImageView.isUserInteractionEnabled = true
        
        let fireTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFireTap))
        self.fireIconImageView.addGestureRecognizer(fireTapGesture)
        self.fireIconImageView.isUserInteractionEnabled = true
    }
    
    func setupPlayer(video: Video) {
        self.addGestures()
        
        self.video = video
        
        let profilePictureURL = URL(string: self.video.profilePicture)
        if let profilePictureURL = profilePictureURL {
            self.delegate?.setupImageFromData(in: self, url: profilePictureURL)
        }
        
        self.videoTitleLabel.text = self.video.body
        
        self.heartCountLabel.text = String(self.video.heartCount)
        self.fireCountLabel.text = String(self.video.fireCount)
        
        guard let videoURL = URL(string: self.video.compressedForIosURL),
              let audioURL = URL(string: self.video.songURL) else {
            return
        }
        
        let videoAsset = AVURLAsset(url: videoURL)
        let audioAsset = AVURLAsset(url: audioURL)
        
        let composition = AVMutableComposition()
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }
        
        do {
            try videoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
        } catch {
            print("Error adding video track: \(error)")
            return
        }
        
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            return
        }
        
        do {
            try audioTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: audioAsset.tracks(withMediaType: .audio)[0], at: .zero)
        } catch {
            print("Error adding audio track: \(error)")
            return
        }
        
        let playerItem = AVPlayerItem(asset: composition)
        
        self.player = AVPlayer(playerItem: playerItem)
        
        self.playerLayer = AVPlayerLayer(player: player)
        
        if let playerLayer = self.playerLayer {
            playerLayer.frame = bounds
            playerLayer.videoGravity = .resizeAspectFill
            self.setupUI(playerLayer: playerLayer)
        }
        
        self.videoLoop(playerItem: playerItem)
        
        if let player = self.player {
            player.play()
        }
    }
    
    private func setupUI(playerLayer: AVPlayerLayer) {
        self.layer.addSublayer(playerLayer)
        
        self.addSubview(self.userImageView)
        self.addSubview(self.videoTitleLabel)
        self.addSubview(self.heartIconImageView)
        self.addSubview(self.heartCountLabel)
        self.addSubview(self.fireIconImageView)
        self.addSubview(self.fireCountLabel)
        
        self.setupUserInfoConstraints()
        self.configureIconConstraints()
    }
    
    private func videoLoop(playerItem: AVPlayerItem) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
    }
    
    private func setupUserInfoConstraints() {
        NSLayoutConstraint.activate([
            self.userImageView.widthAnchor.constraint(equalToConstant: 70),
            self.userImageView.heightAnchor.constraint(equalToConstant: 70),
            self.userImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 48),
            self.userImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            
            self.videoTitleLabel.centerYAnchor.constraint(equalTo: self.userImageView.centerYAnchor),
            self.videoTitleLabel.leftAnchor.constraint(equalTo: self.userImageView.rightAnchor, constant: 12),
            self.videoTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12)
        ])
        
        self.layoutIfNeeded()
        self.userImageView.layer.masksToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
    }
    
    private func configureIconConstraints() {
        NSLayoutConstraint.activate([
            self.heartIconImageView.widthAnchor.constraint(equalToConstant: 48),
            self.heartIconImageView.heightAnchor.constraint(equalToConstant: 48),
            self.heartIconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.heartIconImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
            
            self.heartCountLabel.centerXAnchor.constraint(equalTo: heartIconImageView.centerXAnchor),
            self.heartCountLabel.bottomAnchor.constraint(equalTo: heartIconImageView.topAnchor, constant: -5),
            
            self.fireIconImageView.widthAnchor.constraint(equalToConstant: 48),
            self.fireIconImageView.heightAnchor.constraint(equalToConstant: 48),
            self.fireIconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.fireIconImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12),
            
            self.fireCountLabel.centerXAnchor.constraint(equalTo: fireIconImageView.centerXAnchor),
            self.fireCountLabel.bottomAnchor.constraint(equalTo: fireIconImageView.topAnchor, constant: -5),
        ])
    }
    
    @objc private func playerDidFinishPlaying() {
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func play() {
        self.player?.play()
    }
    
    func resetPlayer() {
        self.player?.seek(to: .zero)
        self.player?.pause()
    }
}
