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
    let profilePictureURL: String
    let username: String
    let compressedForIosURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case songURL = "song_url"
        case body
        case profilePictureURL = "profile_picture_url"
        case username
        case compressedForIosURL = "compressed_for_ios_url"
    }
}
