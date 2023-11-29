//
//  VideoViewModel.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import Foundation

class VideoViewModel {
    
    var video: [Video] = []
    
    private let service = VideoService()
    
    func getVideos() {
        if let path = Bundle.main.path(forResource: "videos", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Videos.self, from: data)
                self.video = jsonData.looks
                
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
                print("rrror: \(error)")
                return
            }
            
            if let data = data {
                completion(data)
            }
        }
    }
}
