//
//  File 2.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

struct DeletedNetflixMovie: Codable {
    var netflixId: String
    
    enum CodingKeys: String, CodingKey {
        case netflixId = "netflixid"
    }
}

struct DeletedNetflixMovieWrapper: Codable {
    var count: String
    var movies: [DeletedNetflixMovie]
    
    enum CodingKeys: String, CodingKey {
        case count = "COUNT"
        case movies = "ITEMS"
    }
}
