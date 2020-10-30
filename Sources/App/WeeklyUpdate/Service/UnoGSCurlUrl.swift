//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

enum UnoGSCurlUrl {
    
    case getCountries
    case search(country: String, page: Int)
    case getAll(page: Int)
    case getDetails(netflixId: String)
    case getNewAdditionsSince(days: Int, country: String)
    case getNewDeletionsSince(days: Int, country: String)
    
    private var baseUrl: String {
        return "https://unogs-unogs-v1.p.rapidapi.com/aaapi.cgi"
    }
    
    private var queryItems: [String: String] {
        switch self {
        case .getCountries:
            return [
                "t": "lc",
                "q": "available"
            ]
        case .search(let country, let page):
            return [
                "q": "-!1900,2018-!0,5-!0,10-!0-!Movie-!Any-!Any-!gt50-!",
                "t": "ns",
                "cl": country,
                "st": "adv",
                "ob": "Relevance",
                "p": String(page),
                "sa": "and"
            ]
        case .getAll(let page):
            return [
                "q": "-!1900,2018-!0,5-!0,10-!0-!Movie-!Any-!Any-!gt50-!",
                "t": "ns",
                "cl": "all",
                "st": "adv",
                "ob": "Relevance",
                "p": String(page),
                "sa": "and"
            ]
        case .getDetails(let netflixId):
            return [
                "t": "loadvideo",
                "q": netflixId
            ]
        case .getNewAdditionsSince(let days, let country):
            return [
                "q": "get:new\(days):\(country.uppercased())",
                "q": "1",
                "t": "ns",
                "st": "adv"
            ]
        case .getNewDeletionsSince(let days, let country):
            return [
                "t": "deleted",
                "cl": country.uppercased(),
                "st": "\(days)"
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
