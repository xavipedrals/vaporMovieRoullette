//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/1/21.
//

import Foundation

enum OMDBCurlUrl {
    
    case getDetail(imdbId: String)
    
    var apiKey: String {
        return "4b0eb9b1"
    }
    
    var baseUrl: String {
        return "http://www.omdbapi.com/"
    }
    
    private var queryItems: [String: String] {
        switch self {
        case .getDetail(let imdbId):
            return [
                "apikey": apiKey,
                "i": imdbId
            ]
        }
    }
    
    var urlString: String {
        let queryItems = self.queryItems
        guard queryItems.count > 0 else {
            return baseUrl
        }
        let queryArr: [String] = queryItems.map { (key, value) -> String in
            return "\(key)=\(value)"
        }
        let query = queryArr.joined(separator: "&")
        return "\(baseUrl)?\(query)"
    }
}
