//
//  File.swift
//
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Vapor
import Fluent

class TMDBEnricher {
    private let rateLimit = RateLimit(calls: 30, timeInSecs: 13)
    var input = [AudioVisual]()
    var currentBatch = [AudioVisual]()
    var group = DispatchGroup()
    let topQueue = DispatchQueue.global(qos: .userInitiated)
    let lowQueue = DispatchQueue.global(qos: .background)
    var lowerBound = 0
    var db: DatabaseHelper

    init(db: DatabaseHelper = DatabaseHelper.shared, input: [AudioVisual]) {
        self.db = db
        self.input = input
    }

    func run(completion: @escaping () -> ()) {
        Commons.printEstimatedTime(itemsCount: input.count, rateLimit: rateLimit)
        group.enter()
        topQueue.async {
            self.doNextBatch()
        }
        group.notify(queue: topQueue) {
            print("------------GOT ALL TMDB ENRICHED INFO------------")
            completion()
        }
    }

    func doNextBatch() {
        guard lowerBound < (input.count - 1) else {
            group.leave()
            return
        }
        print("------------REMAINING ITEMS--------------")
        print(input.count)
        var upperBound = lowerBound + rateLimit.calls
        if upperBound > input.count { upperBound = input.count }
        currentBatch = Array(input[lowerBound..<upperBound])
        let batchController = TMDBatchController(input: currentBatch, queue: lowQueue)
        batchController.delegate = self
        batchController.run()
    }
}

extension TMDBEnricher: TMDBatchDelegate {
    func batchFinished(output: [AudioVisual]) {
        db.update(items: output)
        lowerBound += rateLimit.calls
        doNextBatch()
    }
}


//This class makes futures of network operations
class TMDBEnricherFuture {
    
    let service = TMDBService()
    var audiovisuals: [AudioVisual]
    var eventLoop: EventLoop
    var db: Database
    private let rateLimit = RateLimit(calls: 30, timeInSecs: 13)
    
    init(audiovisuals: [AudioVisual], eventLoop: EventLoop, db: Database) {
        self.audiovisuals = audiovisuals
        self.eventLoop = eventLoop
        self.db = db
    }
    
    func run() -> EventLoopFuture<Void> {
        guard audiovisuals.count > 0 else {
            return eventLoop.makeSucceededFuture(())
        }
        let allEvents = audiovisuals.compactMap(getDetails)
        var resultEvents = [EventLoopFuture<Void>]()
        for e in allEvents {
            let dbEvent = e.flatMap { (a) -> EventLoopFuture<Void> in
                a.save(on: self.db)
            }
            resultEvents.append(dbEvent)
        }
        let chunks = resultEvents.chunked(into: rateLimit.calls)
        var chunkResults = [EventLoopFuture<Void>]()
        for c in chunks {
            let event = EventLoopFuture.andAllComplete(c, on: eventLoop)
            chunkResults.append(event)
        }
        var finalEvent = chunkResults.first!
        for i in 1..<(chunkResults.count) {
            finalEvent = finalEvent.flatMap { () -> EventLoopFuture<Void> in
                let promise = self.eventLoop.makePromise(of: Void.self)
                let q = DispatchQueue(label: "waitQueue-\(i)")
                q.asyncAfter(deadline: .now() + Double(self.rateLimit.timeInSecs)) {
                    promise.succeed(())
                }
                return promise.futureResult
            }.flatMap{ () -> EventLoopFuture<Void> in
                chunkResults[i]
            }
        }
        return finalEvent
    }
    
    //MARK: - Private
    
    func getDetails(target: AudioVisual) -> EventLoopFuture<AudioVisual> {
        let safeId = target.id!.trimmingCharacters(in: .whitespacesAndNewlines)
        let promise = eventLoop.makePromise(of: AudioVisual.self)
        service.getDetailsFrom(imdbId: safeId) { movie in
            guard let m = movie else {
                promise.succeed(target)
                return
            }
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
