//
//  Video.swift
//  software-house-challenge
//
//  Created by Matela on 28/11/23.
//

import Foundation

struct Videos: Codable {
    let looks: [Video]
}

struct Video: Codable {
    let id: Int
    let songURL: String
    let body: String
    let profilePicture: String
    let username: String
    let compressedForIosURL: String
    var heartCount: Int
    var fireCount: Int
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.songURL = try container.decode(String.self, forKey: CodingKeys.songURL)
        self.body = try container.decode(String.self, forKey: .body)
        self.profilePicture = try container.decode(String.self, forKey: CodingKeys.profilePicture)
        self.username = try container.decode(String.self, forKey: .username)
        self.compressedForIosURL = try container.decode(String.self, forKey: CodingKeys.compressedForIosURL)
        self.heartCount = 0
        self.fireCount = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case songURL = "song_url"
        case body
        case profilePicture = "profile_picture_url"
        case username
        case compressedForIosURL = "compressed_for_ios_url"
        case heartCount
        case fireCount
    }
}
