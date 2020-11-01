//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

struct MinifiedMovieList: Codable {
    var id: Int
    var name: String
    var firebaseId: String?
    var ownerId: String?
    var ownerName: String?
    var ownerPicture: String?
    var publishedEpoch: Double?
    var listBackdrop: String?
    var movies: [MinifiedMovie]
}

struct MinifiedMovie: Codable {
    var id: Int
    var title: String?
    var image: String?
    var releaseDate: String?
    var backDropImage: String?
    let genres: [TMDBGenre]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image = "poster_path"
        case releaseDate = "release_date"
        case backDropImage = "backdrop_path"
        case genres
    }
}

extension MinifiedMovie: Hashable {
    static func == (lhs: MinifiedMovie, rhs: MinifiedMovie) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TMDBGenre: Codable {
    var id: Int
    var name: String
}
