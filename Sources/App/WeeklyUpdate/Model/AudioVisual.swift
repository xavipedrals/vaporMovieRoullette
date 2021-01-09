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
    
    @OptionalField(key: "tmdb_id")
    var tmdbId: String?
    
    @OptionalField(key: "title")
    var title: String?
    
    @OptionalField(key: "netflix_rating")
    var netflixRating: Double?
    
    @OptionalField(key: "tmdb_rating")
    var tmdbRating: Double?
    
    @OptionalField(key: "imdb_rating")
    var imdbRating: Double?
    
    @OptionalField(key: "rotten_tomatoes_rating")
    var rottenTomatoesRating: Double?
    
    @Field(key: "available_countries")
    var availableCountries: [String]
    
    @Field(key: "genres")
    var genres: [Int]
    
    @OptionalField(key: "release_year")
    var releaseYear: Int?
    
    @OptionalField(key: "type")
    var type: String? //movie or series
    
    @OptionalField(key: "duration")
    var duration: String?
    
    init() {}
    
    init?(item: NetfilxMovie) {
        guard let id = item.imdbId,
              id != "",
              id != "notfound" else { return nil }
        self.id = id
        self.netflixId = item.netflixId
        self.title = item.title
        self.type = item.type
        if let r = item.netflixRating, let n = Double(r) {
            self.netflixRating = n
        } else {
            self.netflixRating = nil
        }
        //Empty properties
        self.availableCountries = []
        self.genres = []
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
    
    func combined(with tmdbItem: TMDBMovie) {
        self.tmdbId = String(tmdbItem.id)
        self.title = tmdbItem.title ?? self.title
        self.tmdbRating = tmdbItem.rating ?? self.tmdbRating
        var genreSet = Set(self.genres)
        for g in tmdbItem.genres {
            genreSet.insert(g)
        }
        self.genres = genreSet.compactMap { $0 }
        self.releaseYear = tmdbItem.releaseYear ?? self.releaseYear
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

