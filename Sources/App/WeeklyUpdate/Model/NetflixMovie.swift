//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

enum NetflixItemType: String {
    case movie = "movie"
    case series = "series"
    case other
}

struct NetfilxMovie: Codable {
    var imdbId: String
    var netflixId: String
    var title: String
    var type: String?
    var realType: NetflixItemType {
        return NetflixItemType(rawValue: type ?? "movie") ?? .movie
    }
    var netflixRating: String? //Most new additions have rating = 0
    var releaseYear: String?
    
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdbid"
        case netflixId = "netflixid"
        case title
        case type
        case netflixRating = "rating"
        case releaseYear = "released"
    }
}

extension NetfilxMovie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(imdbId)
    }
}

struct NetflixMovieWrapper: Codable {
    var count: String
    var movies: [NetfilxMovie]
    var isMultiPage: Bool {
        guard let c = Int(count) else { return false }
        return c > 100
    }
    var isEndPage: Bool {
        return movies.count == 0
    }
    var isComplete: Bool {
        guard let c = Int(count) else { return false }
        return c <= movies.count
    }
    
    enum CodingKeys: String, CodingKey {
        case count = "COUNT"
        case movies = "ITEMS"
    }
    
    static func combined(_ n1: NetflixMovieWrapper, _ n2: NetflixMovieWrapper) -> NetflixMovieWrapper {
        return NetflixMovieWrapper(
            count: n1.count,
            movies: n1.movies + n2.movies
        )
    }
}
