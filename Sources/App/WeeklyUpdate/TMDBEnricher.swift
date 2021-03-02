//
//  File.swift
//
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Vapor
import Fluent

//This class makes futures of network operations
class TMDBEnricherFuture {
    
    let service = TMDBService()
    var audiovisuals: [AudioVisual]
    var eventLoop: EventLoop
    var db: Database
    private let rateLimit = RateLimit(calls: 30, timeInSecs: 13)
    
    init(audiovisuals: [AudioVisual], eventLoop: EventLoop, db: Database) {
        print("Got \(audiovisuals.count) movies to enrich")
        self.audiovisuals = audiovisuals
        self.eventLoop = eventLoop
        self.db = db
    }
    
    func run() -> EventLoopFuture<Void> {
        guard audiovisuals.count > 0 else {
            print("No movies to enrich")
            return eventLoop.makeSucceededFuture(())
        }
        let chunks = audiovisuals.chunked(into: rateLimit.calls)
        var finalEvent = eventLoop.makeSucceededFuture(())
        for (i, c) in chunks.enumerated() {
            print("Starting chunk \(i) of \(chunks.count)")
            finalEvent = finalEvent.flatMap{ () -> EventLoopFuture<Void> in
                self.getChunk(chunk: c).flatMap {
                    self.getWaitBetweenChunks(i: i)
                }
            }
        }
        return finalEvent
    }
    
    //MARK: - Private
    
    func getChunk(chunk: [AudioVisual]) -> EventLoopFuture<Void> {
        let allEvents = chunk.compactMap(getDetails)
        var resultEvents = [EventLoopFuture<Void>]()
        for e in allEvents {
            let dbEvent = e.flatMap { (a) -> EventLoopFuture<Void> in
                a.save(on: self.db)
            }
            resultEvents.append(dbEvent)
        }
        return EventLoopFuture.andAllComplete(resultEvents, on: eventLoop)
    }
    
    func getWaitBetweenChunks(i: Int) -> EventLoopFuture<Void> {
        let promise = self.eventLoop.makePromise(of: Void.self)
        let q = DispatchQueue(label: "waitQueue-\(i)")
        print("Going to sleep for \(self.rateLimit.timeInSecs) seconds")
        q.asyncAfter(deadline: .now() + Double(self.rateLimit.timeInSecs)) {
            promise.succeed(())
        }
        return promise.futureResult
    }
    
    func getDetails(target: AudioVisual) -> EventLoopFuture<AudioVisual> {
        guard let safeId = target.id?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            print("ERROR: Audiovisual with nexflixId -> \(target.netflixId) has a wrong id")
            return eventLoop.makeSucceededFuture(target)
        }
        print("Enriching movie with \(target.id)")
        let promise = eventLoop.makePromise(of: AudioVisual.self)
        service.getDetailsFrom(imdbId: safeId) { movie in
            guard let m = movie else {
                promise.succeed(target)
                return
            }
            print("Got TMDB result")
            let result = self.enrich(original: target, addition: m)
            promise.succeed(result)
        }
        return promise.futureResult
    }
    
    func enrich(original: AudioVisual, addition: TMDBMovie) -> AudioVisual {
        original.combined(with: addition)
        return original
    }

}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
