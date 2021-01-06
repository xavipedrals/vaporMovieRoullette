//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

//enum TMDBRouter {
//    
//    case search(query: String)
//    case discover
//    case upcoming(page: Int)
//    case configuration
//    case getDetails(id: String, lang: String)
//    case getDetailsFrom(imdbId: String)
//    case getGenres(lang: String)
//    case getMoviesBy(genreId: String)
//    
//    private var baseUrl: String {
//        return "https://api.themoviedb.org/3"
//    }
//    
//    private var apiKey: String {
//        return "fe7f4f801bf1736a864d22f0122648f3"
//    }
//    
//    private var method: String {
//        switch self {
//        case .search, .discover, .upcoming, .configuration, .getDetails, .getDetailsFrom, .getMoviesBy, .getGenres:
//            return "GET"
//        }
//    }
//    
//    private var path: String {
//        switch self {
//        case .search:
//            return "/search/movie"
//        case .discover, .getMoviesBy:
//            return "/discover/movie"
//        case .upcoming:
//            return "/movie/upcoming"
//        case .configuration:
//            return "/configuration"
//        case .getDetails(let id, _):
//            return "/movie/\(id)"
//        case .getDetailsFrom(let imdbId):
//            return "/find/\(imdbId)"
//        case .getGenres:
//            return "/genre/movie/list"
//        }
//    }
//    
//    private var url: URL {
//        var components = URLComponents(string: baseUrl + path)!
//        components.queryItems = queryItems
//        return components.url!
//    }
//    
//    private var queryItems: [URLQueryItem] {
//        let apiKeyQuery = URLQueryItem(name: "api_key", value: apiKey)
//        let language = Locale.preferredLanguages.first ?? "en"
//        let languageQuery = URLQueryItem(name: "language", value: language)
//        switch self {
//        case .discover:
//            return [
//                apiKeyQuery,
//                languageQuery,
//                URLQueryItem(name: "sort_by", value: "popularity.desc"),
//                URLQueryItem(name: "include_adult", value: "false")
//            ]
//        case .upcoming(let page):
//            if let countyCode = Locale.current.regionCode {
//                return [
//                    apiKeyQuery,
//                    languageQuery,
//                    URLQueryItem(name: "region", value: countyCode),
//                    URLQueryItem(name: "page", value: String(page))
//                ]
//            }
//            return [
//                apiKeyQuery,
//                languageQuery,
//                URLQueryItem(name: "page", value: String(page))
//            ]
//        case .search(let query):
//            return [
//                apiKeyQuery,
//                languageQuery,
//                URLQueryItem(name: "query", value: query)
//            ]
//        case .getGenres(let lang):
//            return [
//                apiKeyQuery,
//                URLQueryItem(name: "language", value: lang)
//            ]
//        case .configuration:
//            return [
//                apiKeyQuery,
//                languageQuery
//            ]
//        case .getDetails(_, let lang):
//            return [
//                apiKeyQuery,
//                URLQueryItem(name: "language", value: lang)
//            ]
//        case .getDetailsFrom:
//            return [
//                apiKeyQuery,
//                URLQueryItem(name: "language", value: "en-US"),
//                URLQueryItem(name: "external_source", value: "imdb_id")
//            ]
//        case .getMoviesBy(let genreId):
//            return [
//                apiKeyQuery,
//                languageQuery,
//                URLQueryItem(name: "with_genres", value: genreId),
//                URLQueryItem(name: "include_adult", value: "false"),
//                URLQueryItem(name: "include_video", value: "false"),
//                URLQueryItem(name: "sort_by", value: "popularity.desc")
//            ]
//        }
//    }
//    
//    var urlRequest: URLRequest {
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = method
//        urlRequest.timeoutInterval = 10
//        return urlRequest
//    }
//}
