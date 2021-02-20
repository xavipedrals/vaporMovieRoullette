//
//  TMDBCurlUrl.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 8/1/21.
//

import Foundation

enum TMDBCurlUrl {
    case getDetailsFrom(imdbId: String)
    case getMovieGenres
    case getSeriesGenres
    case getMoviesBy(genreId: String)
    case getSeriesBy(genreId: String)
    
    private var baseUrl: String {
        return "https://api.themoviedb.org/3"
    }
    
    private var path: String {
        switch self {
        case .getDetailsFrom(let imdbId):
            return "/find/\(imdbId)"
        case .getMovieGenres:
            return "/genre/movie/list"
        case .getSeriesGenres:
            return "/genre/tv/list"
        case .getMoviesBy:
            return "/discover/movie"
        case .getSeriesBy:
            return "/discover/tv"
        }
    }
    
    private var apiKey: String {
        return "fe7f4f801bf1736a864d22f0122648f3"
    }
    
    private var queryItems: [String: String] {
        switch self {
        case .getDetailsFrom:
            return [
                "api_key": apiKey,
                "language": "en-US",
                "external_source": "imdb_id"
            ]
        case .getMovieGenres, .getSeriesGenres:
            return [
                "api_key": apiKey,
                "language": "en-US"
            ]
        case .getMoviesBy(let genreId),
             .getSeriesBy(let genreId):
            return [
                "api_key": apiKey,
                "language": "en-US",
                "with_genres": genreId,
                "include_adult": "false",
                "include_video": "false",
                "sort_by": "popularity.desc"
            ]
        }
    }
    
    var urlString: String {
        let queryItems = self.queryItems
        guard queryItems.count > 0 else {
            return baseUrl + path
        }
        let queryArr: [String] = queryItems.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        let query = queryArr.joined(separator: "&")
        return "\(baseUrl)\(path)?\(query)"
    }
}
