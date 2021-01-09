//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

struct TMDBMovie: Codable {
    var id: Int
    var title: String?
    var posterPath: String?
    var genres: [Int]
    var rating: Double?
    var releaseDate: String?
    var releaseYear: Int? {
        guard let date = releaseDate, date != "" else { return nil }
        guard let yearStr = date.split(separator: "-").first else { return nil }
        return Int(String(yearStr))
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case genres = "genre_ids"
        case rating = "vote_average"
        case releaseDate = "release_date"
    }
}

extension TMDBMovie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TDMMovieWrapper: Codable {
    var results: [TMDBMovie]
    var tvEpisodes: [TMDBSeries]
    var allItems: [TMDBMovie] {
        let mapped = tvEpisodes.compactMap{ $0.mapped() }
        return results + mapped
    }
    
    enum CodingKeys: String, CodingKey {
        case results = "movie_results"
        case tvEpisodes = "tv_results"
    }
}

struct TMDBSeries: Codable {
    var id: Int
    var title: String?
    var posterPath: String?
    var genres: [Int]
    var rating: Double?
    var releaseDate: String?
    var releaseYear: Int? {
        guard let date = releaseDate, date != "" else { return nil }
        guard let yearStr = date.split(separator: "-").first else { return nil }
        return Int(String(yearStr))
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case posterPath = "poster_path"
        case genres = "genre_ids"
        case rating = "vote_average"
        case releaseDate = "first_air_date"
    }
    
    func mapped() -> TMDBMovie {
        return TMDBMovie(
            id: self.id,
            title: self.title,
            posterPath: self.posterPath,
            genres: self.genres,
            rating: self.rating,
            releaseDate: self.releaseDate
        )
    }
}
