//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/1/21.
//

import Foundation

struct OMDBMovie: Codable {
    var title: String?
    var releaseDate: String?
    var runtime: String?
    var awards: String?
    var ratings: [OMDBRating]?
    var metascore: String?
    var imdbScore: String?
    var imdbVotes: String?
    var imdbId: String?
    var dvdReleaseDate: String?
    
    var year: Int? {
        guard let split = releaseDate?.split(separator: " ").last else {
            return nil
        }
        let s = String(split)
        return Int(s)
    }
    var imdbRating: Double? {
        if let imdbScore = imdbScore {
            return Double(imdbScore)
        }
        if let imdbValueString = ratings?.first(where: { $0.type == .imdb })?.value {
            return Double(imdbValueString)
        }
        return nil
    }
    var rottenTomatoesRating: Double? {
        if let rottenValueString = ratings?.first(where: { $0.type == .rottenTomatoes })?.value {
            let aux = rottenValueString.replacingOccurrences(of: "%", with: "")
            return Double(aux)
        }
        return nil
    }
    var metacriticRating: Double? {
        if let metascore = metascore {
            return Double(metascore)
        }
        if let metacriticValueString = ratings?.first(where: { $0.type == .metacritic })?.value {
            return Double(metacriticValueString)
        }
        return nil
    }
    var hasRatings: Bool {
        return rottenTomatoesRating != nil
            || imdbRating != nil
            || metacriticRating != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case releaseDate = "Released"
        case runtime = "Runtime"
        case awards = "Awards"
        case ratings = "Ratings"
        case metascore = "Metascore"
        case imdbScore = "imdbRating"
        case imdbVotes = "imdbVotes"
        case imdbId = "imdbID"
        case dvdReleaseDate = "DVD"
    }
    
    init(rottenTomatoesRating: Double?, imdbRating: Double?, metacriticRating: Double?) {
        if let rottenTomatoesRating = rottenTomatoesRating {
            self.ratings = [
                OMDBRating(type: .rottenTomatoes, value: String(rottenTomatoesRating))
            ]
        }
        if let imdbRating = imdbRating {
            self.imdbScore = String(imdbRating)
        }
        if let metacriticRating = metacriticRating {
            self.metascore = String(metacriticRating)
        }
    }
}

struct OMDBRating: Codable {
    
    enum RatingSource: String {
        case rottenTomatoes = "Rotten Tomatoes"
        case imdb = "Internet Movie Database"
        case metacritic = "Metacritic"
    }
    
    var source: String
    var value: String
    var type: RatingSource? {
        return RatingSource(rawValue: source)
    }
    
    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
    
    init(type: RatingSource, value: String) {
        self.source = type.rawValue
        self.value = value
    }
}
