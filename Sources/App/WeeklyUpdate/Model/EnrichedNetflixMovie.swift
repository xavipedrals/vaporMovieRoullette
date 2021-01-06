//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Vapor
import Fluent

final class AudioVisual: Model {
    
    static let schema = "audiovisuals"
    
    @ID(custom: "imdb_id", generatedBy: .user)
    var id: String? //IMDBID
    
    @Field(key: "netflix_id")
    var netflixId: String
    
    @Field(key: "tmdb_id")
    var tmdbId: String?
    
    @Field(key: "title")
    var title: String?
    
    @Field(key: "netflix_rating")
    var netflixRating: Double?
    
    @Field(key: "tmdb_rating")
    var tmdbRating: Double?
    
    @Field(key: "imdb_rating")
    var imdbRating: Double?
    
    @Field(key: "rottenTomatoesRating")
    var rottenTomatoesRating: Double?
    
    @Field(key: "availableCountries")
    var availableCountries: [String]
    
    @Field(key: "genres")
    var genres: [Int]
    
    @Field(key: "releaseYear")
    var releaseYear: Int?
    
    @Field(key: "type")
    var type: String? //movie or series
    
    @Field(key: "duration")
    var duration: String?
}

//
//    init(movie: NetfilxMovie) {
//        self.imdbId = movie.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
//        self.netflixId = movie.netflixId
//        self.title = movie.title
//        if let rating = movie.netflixRating {
//            self.netflixRating = Double(rating)
//        }
//        availableCountries = []
//        genres = []
//        if let year = movie.releaseYear {
//            self.releaseYear = Int(year)
//        }
//    }
//
//    mutating func enrich(from movie: TMDBMovie) {
//        self.title = movie.title ?? self.title
//        self.tmdbId = String(movie.id)
//        self.genres = movie.genres
//        self.tmdbRating = movie.rating
//        self.releaseYear = movie.releaseYear ?? self.releaseYear
//    }
//}
//
//extension EnrichedNetflixMovie: Hashable {
//    static func == (lhs: EnrichedNetflixMovie, rhs: EnrichedNetflixMovie) -> Bool {
//        return lhs.netflixId == rhs.netflixId
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine("\(imdbId)\(netflixId)")
//    }
//}


//Migrations only run once: Once they run in a database, they never execute again. So, Fluent won’t attempt to recreate a table if you change the migration.
struct CreateMoviesSchema: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("audiovisuals")
//            .id()
            .field("imdb_id", .string, .identifier(auto: false))
            .field("netflix_id", .string, .required)
            .field("tmdb_id", .string)
            .field("title", .string)
            .field("netflix_rating", .double)
            .field("tmdb_rating", .double)
            .field("imdb_rating", .double)
            .field("rotten_tomatoes_rating", .double)
            .field("available_countries", .array(of: .string))
            .field("genres", .array(of: .int))
            .field("release_year", .int)
            .field("type", .string)
            .field("duration", .string)
            .create()
    }
        
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("audiovisuals").delete()
    }
}
