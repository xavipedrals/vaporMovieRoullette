//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

struct EnrichedNetflixMovie: Codable {
    var imdbId: String
    var netflixId: String
    var tmdbId: String?
    var title: String
    var netflixRating: Double?
    var tmdbRating: Double?
    var availableCountries: [NetflixCountry]
    var genres: [Int]
    var releaseYear: Int?
    
    init(movie: NetfilxMovie) {
        self.imdbId = movie.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
        self.netflixId = movie.netflixId
        self.title = movie.title
        if let rating = movie.netflixRating {
            self.netflixRating = Double(rating)
        }
        availableCountries = []
        genres = []
        if let year = movie.releaseYear {
            self.releaseYear = Int(year)
        }
    }
    
    mutating func enrich(from movie: TMDBMovie) {
        self.title = movie.title ?? self.title
        self.tmdbId = String(movie.id)
        self.genres = movie.genres
        self.tmdbRating = movie.rating
        self.releaseYear = movie.releaseYear ?? self.releaseYear
    }
}

extension EnrichedNetflixMovie: Hashable {
    static func == (lhs: EnrichedNetflixMovie, rhs: EnrichedNetflixMovie) -> Bool {
        return lhs.netflixId == rhs.netflixId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(imdbId)\(netflixId)")
    }
}
