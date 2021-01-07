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
    
    @Field(key: "rotten_tomatoes_rating")
    var rottenTomatoesRating: Double?
    
    @Field(key: "available_countries")
    var availableCountries: [String]
    
    @Field(key: "genres")
    var genres: [Int]
    
    @Field(key: "release_year")
    var releaseYear: Int?
    
    @Field(key: "type")
    var type: String? //movie or series
    
    @Field(key: "duration")
    var duration: String?
    
    init() {}
    
    init(item: NetfilxMovie) {
        self.id = item.imdbId
        self.netflixId = item.netflixId
        self.title = item.title
        if let r = item.netflixRating, let n = Double(r) {
            self.netflixRating = n
        }
    }
    
    //TODO: Write different combine funcs per netflix and TMDB
    func combined(with: AudioVisual, country: String?) {
        if let c = country {
            add(country: c)
        }
        self.netflixId = with.netflixId
        self.tmdbId = with.tmdbId ?? self.tmdbId
        self.title = with.title ?? self.title
        if let r = with.netflixRating, r > 0 {
            self.netflixRating = with.netflixRating
        }
        self.tmdbRating = with.tmdbRating ?? self.tmdbRating
        self.imdbRating = with.imdbRating ?? self.imdbRating
        self.rottenTomatoesRating = with.rottenTomatoesRating ?? self.rottenTomatoesRating
        var genreSet = Set(self.genres)
        for g in with.genres {
            genreSet.insert(g)
        }
        self.genres = genreSet.compactMap { $0 }
        self.releaseYear = with.releaseYear ?? self.releaseYear
        self.type = with.type ?? self.type
        self.duration = with.duration ?? self.duration
    }
    
    func add(country: String) {
        guard !availableCountries.contains(country) else {
            return
        }
        availableCountries.append(country)
    }
    
    func remove(country: String) {
        guard availableCountries.contains(country) else {
            return
        }
        var countries = Set(availableCountries)
        countries.remove(country)
        availableCountries = countries.compactMap{ $0 }
    }
}

