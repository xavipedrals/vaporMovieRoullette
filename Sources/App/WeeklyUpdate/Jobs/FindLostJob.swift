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
            let top = 99 > movies.count ? movies.count : 99
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
            guard let details = m,
                  self.canMovieBeInserted(movie: details) else {
                print("movie with id -> \(movie.id) can't be made into audiovisual")
                return self.reinsert(notFound: movie)
            }
//            print(details)
//            print("INSERTING new audiovisual")
            return self.insertOrUpdate(details: details).flatMap { () -> EventLoopFuture<Void> in
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
        return movie.countries.count > 0 && movie.imdbId != nil
    }
    
    func reinsert(notFound: NotFoundNetflix) -> EventLoopFuture<Void> {
        databaseHelper.update(notFound: notFound)
    }
    
    func insertOrUpdate(details: NetflixDetails) -> EventLoopFuture<Void> {
        let audiovisual = details.transform()
        guard audiovisual.id != nil else {
            print("Audiovisual does not have an id, skipping")
            return eventLoop.makeSucceededFuture(())
        }
        return AudioVisual.find(audiovisual.id, on: databaseHelper.db).flatMap { a -> EventLoopFuture<Void> in
            guard let dbAudiovisual = a else {
                print("Inserting new audiovisual")
                return audiovisual.save(on: self.databaseHelper.db)
            }
            dbAudiovisual.availableCountries = audiovisual.availableCountries
            dbAudiovisual.netflixRating = audiovisual.netflixRating
            print("Updating existing audiovisual")
            return dbAudiovisual.save(on: self.databaseHelper.db)
        }
    }
    
    func delete(notFound: NotFoundNetflix) -> EventLoopFuture<Void> {
        return notFound.delete(force: true, on: databaseHelper.db)
    }
    
    //MARK: - Telegram single insert
    
    func getDetailsFor(netflixId: String) -> EventLoopFuture<Void> {
        let m = NotFoundNetflix(netflixId: netflixId, title: nil)
        return treat(movie: m)
    }
    
    func getDetailsFor(netflixIds: [String]) -> EventLoopFuture<Void> {
        return filter(netflixIds: netflixIds, limit: 60).flatMap { (uniqueIds) -> EventLoopFuture<Void> in
            var event = self.eventLoop.makeSucceededFuture(())
            for id in uniqueIds {
                event = event.flatMap{ () -> EventLoopFuture<Void> in
                    print("Adding countries to movie with id \(id)")
                    return self.getDetailsFor(netflixId: id)
                }
            }
            return event
        }
    }
    
    private func filter(netflixIds: [String], limit: Int) -> EventLoopFuture<[String]> {
        var event = eventLoop.makeSucceededFuture([String]())
        for id in netflixIds {
            event = event.flatMap{ (accum) -> EventLoopFuture<[String]> in
                guard accum.count <= limit else {
                    return self.eventLoop.makeSucceededFuture(accum)
                }
                return AudioVisual.query(on: self.databaseHelper.db).filter(\.$netflixId == id)
                    .first().map { (a) -> [String] in
                        guard let audiovisual = a else {
                            print("Fetching new movie with id \(id)")
                            var arrWithExtra = accum
                            arrWithExtra.append(id)
                            return arrWithExtra
                        }
                        guard audiovisual.availableCountries.count < 15 else {
                            print("Movie with id \(id) has all countries already")
                            return accum
                        }
                        print("Adding countries to movie with id \(id)")
                        var arrWithExtra = accum
                        arrWithExtra.append(id)
                        return arrWithExtra
                    }
            }
        }
        return event
    }
    
}
