//
//  UnoGSRouter.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

enum UnoGSRouter {
    
    case getCountries
    case search(country: String, page: Int)
    case getAll(page: Int)
    case getDetails(netflixId: String)
    case getNewAdditionsSince(days: Int, country: String)
    case getNewDeletionsSince(days: Int, country: String)
    
    private var baseUrl: String {
        return "https://unogs-unogs-v1.p.rapidapi.com/aaapi.cgi"
    }
    
    private var apiKey: String {
        guard let key = UnoGSAPIKeyManager().getKey() else {
            fatalError("All UNOGS keys have been used to the limit")
        }
        return key
    }
    
    private var method: String {
        return "GET"
    }
    
    private var headers: [String: String] {
        return ["X-RapidAPI-Key": apiKey]
    }
    
    private var queryItems: [URLQueryItem] {
        switch self {
        case .getCountries:
            return [
                URLQueryItem(name: "t", value: "lc"),
                URLQueryItem(name: "q", value: "available")
            ]
        case .search(let country, let page):
            return [
                URLQueryItem(name: "q", value: "-!1900,2018-!0,5-!0,10-!0-!Movie-!Any-!Any-!gt50-!"),
                URLQueryItem(name: "t", value: "ns"),
                URLQueryItem(name: "cl", value: country),
                URLQueryItem(name: "st", value: "adv"),
                URLQueryItem(name: "ob", value: "Relevance"),
                URLQueryItem(name: "p", value: String(page)),
                URLQueryItem(name: "sa", value: "and")
            ]
        case .getAll(let page):
            return [
                URLQueryItem(name: "q", value: "-!1900,2018-!0,5-!0,10-!0-!Movie-!Any-!Any-!gt50-!"),
                URLQueryItem(name: "t", value: "ns"),
                URLQueryItem(name: "cl", value: "all"),
                URLQueryItem(name: "st", value: "adv"),
                URLQueryItem(name: "ob", value: "Relevance"),
                URLQueryItem(name: "p", value: String(page)),
                URLQueryItem(name: "sa", value: "and")
            ]
        case .getDetails(let netflixId):
            return [
                URLQueryItem(name: "t", value: "loadvideo"),
                URLQueryItem(name: "q", value: netflixId)
            ]
        case .getNewAdditionsSince(let days, let country):
            return [
                URLQueryItem(name: "q", value: "get:new\(days):\(country.uppercased())"),
                URLQueryItem(name: "q", value: "1"),
                URLQueryItem(name: "t", value: "ns"),
                URLQueryItem(name: "st", value: "adv")
            ]
        case .getNewDeletionsSince(let days, let country):
            return [
                URLQueryItem(name: "t", value: "deleted"),
                URLQueryItem(name: "cl", value: country.uppercased()),
                URLQueryItem(name: "st", value: "\(days)")
            ]
        }
    }
    
    private var url: URL {
        var components = URLComponents(string: baseUrl)!
        components.queryItems = queryItems
        return components.url!
    }
    
    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.allHTTPHeaderFields = headers
        return urlRequest
    }
}
