//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

struct DetailsNetflixMovie: Codable {
    var info: NetflixMovieDetailInfo
    var countries: [NetflixCountry]
    
    enum CodingKeys: String, CodingKey {
        case info = "nfinfo"
        case countries = "country"
    }
}

struct NetflixMovieDetailRoot: Codable {
    var result: DetailsNetflixMovie
    
    enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

struct NetflixMovieDetailInfo: Codable {
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "netflixid"
    }
}
