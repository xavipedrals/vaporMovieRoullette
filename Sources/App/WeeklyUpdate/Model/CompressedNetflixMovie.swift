//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

struct CompressedNetflixMovie: Codable {
    var imdbId: String
    var netflixId: String
    var tmdbId: String?
    var title: String
    var netflixRating: Double?
    var tmdbRating: Double?
    var availableCountries: [String] //only 2 letters country code
    var genres: [Int]
    var releaseYear: Int?
    
//    init(movie: EnrichedNetflixMovie) {
//        self.imdbId = movie.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
//        self.tmdbId = movie.tmdbId
//        self.netflixId = movie.netflixId
//        self.title = movie.title
//        if let rating = movie.netflixRating {
//            self.netflixRating = Double(rating)
//        }
//        availableCountries = movie.availableCountries.compactMap({ $0.code })
//        genres = movie.genres
//        if let year = movie.releaseYear {
//            self.releaseYear = Int(year)
//        }
//    }
}

extension CompressedNetflixMovie: Hashable {
    static func == (lhs: CompressedNetflixMovie, rhs: CompressedNetflixMovie) -> Bool {
        return lhs.netflixId == rhs.netflixId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imdbId)
    }
}
