//
//  VideoService.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import Foundation

class VideoService {
    
    func fetchImageFromURL(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            completion(data, error)
        }
        task.resume()
    }
}
