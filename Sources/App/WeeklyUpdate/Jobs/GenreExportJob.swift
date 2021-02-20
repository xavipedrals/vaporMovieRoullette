//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 20/2/21.
//

import Vapor

class GenreExportJob {
    
    var eventLoop: EventLoop!
    let service = TMDBService()
//    var filledGenreIds = Set<Int>()
//    var allGenreIds = Set<Int>()
    var usedBackdrops = Set<String>()
    var finalGenres = [Genre]()
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func run() -> EventLoopFuture<Void> {
        return getMovieGenres().and(getSeriesGenres()).map { (g1, g2) -> ([Genre]) in
            return g1 + g2
        }
        .flatMap(addBackdropsFor)
        .map {
            CustomFileManager.instance.write(array: self.finalGenres, filename: "genres.json")
        }
    }
    
    func addBackdropsFor(genres: [Genre]) -> EventLoopFuture<Void> {
        var event: EventLoopFuture<Void> = eventLoop.makeSucceededFuture(())
        for g in genres {
            event = event.flatMap { () -> EventLoopFuture<Void> in
                self.getMoviesFor(genre: g)
            }
        }
        return event
    }
    
    func getMovieGenres() -> EventLoopFuture<[Genre]> {
        let promise = eventLoop.makePromise(of: [Genre].self)
        service.getMovieGenres { genres in
            promise.succeed(genres)
        }
        return promise.futureResult
    }
    
    func getSeriesGenres() -> EventLoopFuture<[Genre]> {
        let promise = eventLoop.makePromise(of: [Genre].self)
        service.getSeriesGenres { genres in
            var result = genres
            for i in 0 ..< result.count {
                result[i].isMovie = false
            }
            promise.succeed(result)
        }
        return promise.futureResult
    }
    
    func getMoviesFor(genre: Genre) -> EventLoopFuture<Void> {
        let promise = eventLoop.makePromise(of: Void.self)
        service.getMoviesOfGenre(id: genre.id) { movies in
            self.addBackdropFor(targetGenre: genre, movies: movies)
            promise.succeed(())
        }
        return promise.futureResult
    }
    
    func addBackdropFor(targetGenre: Genre, movies: [Movie]) {
        for movie in movies {
            guard let backdrop = movie.backdrop,
                !usedBackdrops.contains(backdrop) else { continue }
            
            var aux = targetGenre
            aux.backdropImage = backdrop
            finalGenres.append(aux)
            usedBackdrops.insert(backdrop)
            return
        }
    }
}
