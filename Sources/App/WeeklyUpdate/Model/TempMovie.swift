//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 2/3/21.
//

import Foundation
import Vapor
import Fluent

struct TempMovie: Codable {
    var netflixId: String
    var title: String
}

class TempMovieManager {
    
    func addMoviesToNotFound() {
        let data = CustomFileManager.instance.readFile(name: "moviesInput.json")
        let movies = (try? JSONDecoder().decode([TempMovie].self, from: data)) ?? []
        print("Got \(movies.count) movies to insert")
        let db = DatabaseHelper.shared.db
        for movie in movies {
            let audiovisual = try? AudioVisual.query(on: db!)
                .filter(\.$netflixId == movie.netflixId)
                .first()
                .wait()
            guard audiovisual == nil else {
                print("Movie with netflixId -> \(movie.netflixId) found on audiovisuals")
                continue
            }
            let nf = try? NotFoundNetflix.find(movie.netflixId, on: db!).wait()
            guard nf == nil else {
                print("Movie with netflixId -> \(movie.netflixId) found on notFoundMovies")
                continue
            }
            let notFoundMovie = NotFoundNetflix(netflixId: movie.netflixId, title: movie.title)
            try? notFoundMovie.save(on: db!).wait()
        }
    }
    
}
