//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 10/1/21.
//

import Vapor
import Queues
import Fluent
import FluentPostgresDriver

class DailyJob: ScheduledJob {
    
    var completion: () -> ()
    var db: Database!
    var databaseHelper: DatabaseHelper!
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        let db = context.application.db
        self.db = db
        databaseHelper = DatabaseHelper()
        databaseHelper.db = db
        start()
        return context.eventLoop.makeSucceededFuture(())
    }
    
    func start() {
        WeeklyUpdateOption(completion: { _ in
            self.refreshTMDBInfo()
        }).run()
    }
    
    //MARK: - Private
    
    func refreshTMDBInfo() {
        let itemsToEnrich = databaseHelper.getItemsToTMDBEnrich()
        TMDBEnricher(db: databaseHelper, input: itemsToEnrich).run {
            self.refreshRatings()
        }
    }
    
    func refreshRatings() {
        let noRatingItems = databaseHelper.getItemsWithoutRating()
        OMDBEnricher(db: databaseHelper, input: noRatingItems, completion: { _ in
            self.completion()
        }).run()
    }
}


class RecoveryDailyJob: ScheduledJob {
    
//    var completion: () -> ()
    var db: Database!
    var databaseHelper: DatabaseHelper!
    
//    init(completion: @escaping () -> ()) {
//        self.completion = completion
//    }
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        let db = context.application.db
        self.db = db
        databaseHelper = DatabaseHelper()
        databaseHelper.db = db
        print("Setting up promise")
        let promise = context.eventLoop.makePromise(of: Void.self)
        start() {
            promise.succeed(())
        }
        return promise.futureResult
//        return context.eventLoop.makeSucceededFuture(())
    }
    
    func start(completion: @escaping () -> ()) {
        guard let n = getUpdateDiff(operation: .addition, country: .argentina),
              n > 0 else {
            print("No need for a recovery daily job")
            return
        }
        WeeklyUpdateOption(completion: { _ in
            self.refreshTMDBInfo(completion: completion)
        }).run()
    }
    
    //MARK: - Private
    
    func getUpdateDiff(operation: NetflixOperation, country: CountryCodes) -> Int? {
        let op = databaseHelper.get(country: country, op: operation)
        guard let lastUpdate = op?.updatedAt else {
            print("No date in database")
            return nil //If there's nothing in the db don't proceed
        }
        let diff = CalendarManager().getMissingDays(from: lastUpdate, to: Date())
        print("Difference between updates -> \(diff) days")
        return diff
    }
    
    func refreshTMDBInfo(completion: @escaping () -> ()) {
        let itemsToEnrich = databaseHelper.getItemsToTMDBEnrich()
        TMDBEnricher(db: databaseHelper, input: itemsToEnrich).run {
            self.refreshRatings(completion: completion)
        }
    }
    
    func refreshRatings(completion: @escaping () -> ()) {
        let noRatingItems = databaseHelper.getItemsWithoutRating()
        OMDBEnricher(db: databaseHelper, input: noRatingItems, completion: { _ in
            completion()
        }).run()
    }
}

class SidaJob: ScheduledJob {
    
    var databaseHelper: DatabaseHelper!
    var eventLoop: EventLoop!
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        databaseHelper = DatabaseHelper()
        databaseHelper.db = context.application.db
        eventLoop = context.eventLoop
        let country = CountryCodes.japan
        return databaseHelper.getFuture(country: country, op: .deletion).flatMap { (op) -> EventLoopFuture<Void> in
            guard let diff = self.getUpdateDiff(operation: op) else {
                print("No need for an update in country -> \(op)")
                return self.eventLoop.makeSucceededFuture(())
            }
            let c = NetflixDeletionsFuture(
                databaseHelper: self.databaseHelper,
                eventLoop: self.eventLoop,
                country: country,
                updateDiff: diff
            )
            return c.run()
        }
        
        
//        let start = databaseHelper.getFuture(country: country, op: .addition)
//        let op = start.flatMap { (op) ->
//            EventLoopFuture<[NetfilxMovie]> in
//            self.getNetfixAdditions(op: op, country: country)
//        }
//        let pit = op.flatMap { (movies) -> EventLoopFuture<Void> in
//            self.saveMovies(movies, country: country)
//        }
//        let culo = pit.flatMap { () -> EventLoopFuture<Void> in
//            self.databaseHelper.insertOrUpdateFuture(country: country, op: .addition)
//        }
//        return culo
    }
    
    //MARK: - Private
    
//    func saveMovies(_ movies: [NetfilxMovie], country: CountryCodes) -> EventLoopFuture<Void> {
//        print("Got movies -> \(movies.count)")
//        let bdOps = self.databaseHelper.insertOrUpdateNetflixFuture(items: movies, country: country.rawValue)
//        return EventLoopFuture.reduce((), bdOps, on: eventLoop) { (accumulated, newValue) -> () in
//            return ()
//        }
//    }
//
//    func getNetfixAdditions(op: OperationPerCountry?, country: CountryCodes) -> EventLoopFuture<[NetfilxMovie]> {
//        print("Got op -> \(op)")
//        guard let diff = self.getUpdateDiff(operation: op) else {
//            print("No need for an update in country -> \(op)")
//            return eventLoop.makeSucceededFuture([])
//        }
//        let s = NetflixUpdateController(country: country, updateDiffDays: diff)
//        return s.getAdditions(eventLoop: eventLoop)
//    }
    
    func getUpdateDiff(operation: OperationPerCountry?) -> Int? {
        guard let lastUpdate = operation?.updatedAt else {
            print("No date in database")
            return nil //If there's nothing in the db don't proceed
        }
        let diff = CalendarManager().getMissingDays(from: lastUpdate, to: Date())
        print("Difference between updates -> \(diff) days")
        return diff
    }
}
