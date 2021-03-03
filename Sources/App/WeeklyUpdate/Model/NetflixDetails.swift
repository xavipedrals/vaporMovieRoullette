//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 3/3/21.
//

import Foundation

struct NetflixDetailsWrapper: Codable {
    var item: NetflixDetails
    
    enum CodingKeys: String, CodingKey {
        case item = "RESULT"
    }
}

struct NetflixDetails: Codable {
    fileprivate var nfinfo: NetflixDetailsNfInfo
    fileprivate var imdbinfo: NetflixDetailsImdbInfo
    fileprivate var country: [NetflixDetailsCountry]
    var countries: [CountryCodes] {
        return country.compactMap{ CountryCodes(rawValue: $0.code) }
    }
    
    func transform() -> AudioVisual {
        let a = AudioVisual()
        a.id = imdbinfo.imdbId
        a.availableCountries = countries.compactMap{ $0.rawValue }
        a.netflixId = nfinfo.netflixId
        a.title = nfinfo.title
        a.netflixRating = Double(nfinfo.rating ?? "")
        a.imdbRating = Double(imdbinfo.rating ?? "")
        a.type = nfinfo.type
        return a
    }
}

fileprivate struct NetflixDetailsNfInfo: Codable {
    var rating: String?
    var type: String
    var netflixId: String
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case rating = "avgrating"
        case type
        case netflixId = "netflixid"
        case title
    }
}

fileprivate struct NetflixDetailsImdbInfo: Codable {
    var rating: String?
    var imdbId: String
    
    enum CodingKeys: String, CodingKey {
        case rating = "rating"
        case imdbId = "imdbid"
    }
}

fileprivate struct NetflixDetailsCountry: Codable {
    var name: String
    var code: String //2 letters code like "es"
    
    enum CodingKeys: String, CodingKey {
        case name = "country"
        case code = "ccode"
    }
}
