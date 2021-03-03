//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 3/3/21.
//

import Vapor
import Fluent

class FindLostJob {
    
    var databaseHelper: DatabaseHelper!
    var eventLoop: EventLoop!
    
    init(databaseHelper: DatabaseHelper, eventLoop: EventLoop) {
        self.databaseHelper = databaseHelper
        self.eventLoop = eventLoop
    }
    
    func run() -> EventLoopFuture<Void> {
        return databaseHelper.getOldestNotFound().flatMap { (movies) -> EventLoopFuture<Void> in
            let top = 90 > movies.count ? movies.count : 90
            return self.handle(movies: Array(movies[0 ..< top]))
        }
    }
    
    func handle(movies: [NotFoundNetflix]) -> EventLoopFuture<Void> {
        var event: EventLoopFuture<Void> = eventLoop.makeSucceededFuture(())
        for movie in movies {
            event = event.flatMap { () -> EventLoopFuture<Void> in
                return self.treat(movie: movie)
            }
        }
        return event
    }
    
    func treat(movie: NotFoundNetflix) -> EventLoopFuture<Void> {
        return getDetails(movie: movie).flatMap { (m) -> EventLoopFuture<Void> in
            guard let details = m else {
                return self.eventLoop.makeSucceededFuture(())
            }
            guard self.canMovieBeInserted(movie: details) else {
                return self.reinsert(notFound: movie)
            }
            return self.insertNew(details: details).flatMap { () -> EventLoopFuture<Void> in
                self.delete(notFound: movie)
            }
        }
    }
    
    func getDetails(movie: NotFoundNetflix) -> EventLoopFuture<NetflixDetails?> {
        let promise = eventLoop.makePromise(of: NetflixDetails?.self)
        guard let id = movie.id else {
            return eventLoop.makeSucceededFuture(nil)
        }
        UnoGSService().getDetailsFor(netflixId: id) { (details) in
            promise.succeed(details)
        }
        return promise.futureResult
    }
    
    func canMovieBeInserted(movie: NetflixDetails) -> Bool {
        return movie.countries.count > 0
    }
    
    func reinsert(notFound: NotFoundNetflix) -> EventLoopFuture<Void> {
        databaseHelper.update(notFound: notFound)
    }
    
    func insertNew(details: NetflixDetails) -> EventLoopFuture<Void> {
        let audiovisual = details.transform()
        guard audiovisual.id != nil else {
            return eventLoop.makeSucceededFuture(())
        }
        return audiovisual.save(on: databaseHelper.db)
    }
    
    func delete(notFound: NotFoundNetflix) -> EventLoopFuture<Void> {
        return notFound.delete(force: true, on: databaseHelper.db)
    }
    
}
