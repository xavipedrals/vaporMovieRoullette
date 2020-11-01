//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

public struct GenreWrapper: Codable {
    public var genres: [Genre]
    
    public init(genres: [Genre]) {
        self.genres = genres
    }
}

public struct Genre: Codable {
    public var id: Int
    public var name: String
    public var backdropImage: String?
    
    public init(id: Int, name: String, backdropImage: String?) {
        self.id = id
        self.name = name
        self.backdropImage = backdropImage
    }
}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Genre: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct MovieWrapper: Codable {
    public var results: [Movie]
}

public struct Movie: Codable {
    public var genres: [Int]?
    public var backdrop: String?
    
    public enum CodingKeys: String, CodingKey {
        case genres = "genre_ids"
        case backdrop = "backdrop_path"
    }
}
