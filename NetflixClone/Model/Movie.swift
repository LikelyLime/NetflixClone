//
//  Movie.swift
//  NetflixClone
//
//  Created by 백시훈 on 8/1/24.
//

import Foundation
struct MovieResponse: Codable{
    let results: [Movie]
}

struct Movie: Codable{
    let id: Int?
    let title: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey{
        case id, title
        case posterPath = "poster_path"
    }
}
