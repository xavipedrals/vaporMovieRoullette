//
//  TMDBCurlUrl.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 8/1/21.
//

import Foundation

enum TMDBCurlUrl {
    case getDetailsFrom(imdbId: String)
    
    private var baseUrl: String {
        return "https://api.themoviedb.org/3"
    }
    
    private var path: String {
        switch self {
        case .getDetailsFrom(let imdbId):
            return "/find/\(imdbId)"
        default:
            return ""
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
