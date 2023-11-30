//
//  VideoViewModel.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import Foundation

class VideoViewModel {
    
    var videos: [Video] = []
    
    private let service = VideoService()
    
    func getVideos() {
        if let path = Bundle.main.path(forResource: "videos", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Videos.self, from: data)
                self.videos = jsonData.looks
                
            } catch {
                print("error: \(error)")
            }
        } else {
            print("JSON not found.")
        }
    }
    
    func loadImageFromURL(url: URL, completion: @escaping (Data) -> ()) {
        self.service.fetchImageFromURL(url: url) { data, error in
            if let error = error {
                print("error: \(error)")
                return
            }
            
            if let data = data {
                completion(data)
            }
        }
    }
    
    func increaseHeartOrFireCount(tag: Int, video: Video) {
        if let index = self.videos.firstIndex(where: { $0.id == video.id }) {
            if tag == 1 {
                self.videos[index].heartCount += 1
            } else {
                self.videos[index].fireCount += 1
            }
        }
    }
}
