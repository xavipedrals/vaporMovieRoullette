//
//  OMDBEnricher.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/1/21.
//

import Vapor
import Fluent

class OMDBEnricher {
    
    var input = [AudioVisual]()
    let service = OMDBService()
    var group = DispatchGroup()
    var completion: (_ success: Bool) -> ()
    var currentIndex = -1
    var db: DatabaseHelper
    
    init(db: DatabaseHelper = DatabaseHelper.shared, input: [AudioVisual], completion: @escaping (_ success: Bool) -> ()) {
        self.db = db
        self.completion = completion
        self.input = input
    }
    
    func run() {
        getNextRating()
    }
    
    func moveToNextItem() -> Bool {
        print("Items left -> \(input.count - currentIndex)")
        currentIndex += 1
        guard currentIndex < (input.count - 1) else {
            print("Finished with success!")
            completion(true)
            return false
        }
        return true
    }
    
    func getNextRating() {
        group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        guard moveToNextItem() else { return }
        group.enter()
        queue.async {
            self.getRating()
        }
        group.notify(queue: .global(qos: .utility)) {
            print("Queue cleared")
            self.getNextRating()
        }
    }
    
    func getRating() {
        guard let imdbId = input[currentIndex].id else {
            self.group.leave()
            return
        }
        service.getDetailsFrom(imdbId: imdbId) { omdbMovie in
            defer { self.group.leave() }
            guard let o = omdbMovie else {
                return
            }
            let audiovisual = self.input[self.currentIndex]
            audiovisual.combined(with: o)
            self.db.update(items: [audiovisual])
        }
    }
}

//This class makes futures of network operations
class OMDBEnricherFuture {
    
    let service = OMDBService()
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
        
        service.getDetailsFrom(imdbId: safeId) { omdbMovie in
            guard let o = omdbMovie else {
                promise.succeed(target)
                return
            }
            target.combined(with: o)
            promise.succeed(target)
        }
        return promise.futureResult
    }
    
    func enrich(original: AudioVisual, addition: OMDBMovie) -> AudioVisual {
        original.combined(with: addition)
        return original
    }

}
