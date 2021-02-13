//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 13/2/21.
//

import Foundation

struct ExportMovie: Codable {
    var imdbId: String
    var netflixId: String
    var tmdbId: String?
    var title: String
    var type: String
    var genres: [Int]
    var releaseYear: Int?
    var duration: String?
    var netflixRating: String?
    var imdbRating: String?
    var tmdbRating: String?
    var rottenTomatoesRating: String?
    var metacriticRating: String?
        
    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case netflixId = "netflix_id"
        case tmdbId = "tmdb_id"
        case title
        case type
        case genres
        case releaseYear = "release_year"
        case duration
        case netflixRating = "netflix_rating"
        case imdbRating = "imdb_rating"
        case tmdbRating = "tmdb_rating"
        case rottenTomatoesRating = "rotten_tomatoes_rating"
        case metacriticRating = "metacritic_rating"
    }
}
