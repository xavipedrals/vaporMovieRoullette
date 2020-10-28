//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

enum NetflixItemType: String {
    case movie = "movie"
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
    var netflixRating: String?
    var releaseYear: String?
    
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdbid"
        case netflixId = "netflixid"
        case title
        case type
        case netflixRating = "rating"
        case releaseYear = "released"
    }
    
    init(from enrichedMovie: EnrichedNetflixMovie) {
        self.imdbId = enrichedMovie.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.netflixId = enrichedMovie.netflixId
        self.title = enrichedMovie.title
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
    
    enum CodingKeys: String, CodingKey {
        case count = "COUNT"
        case movies = "ITEMS"
    }
}
