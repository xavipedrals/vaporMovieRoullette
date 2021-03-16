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

class DailyJobFuture: ScheduledJob {
    
    var databaseHelper: DatabaseHelper!
    var eventLoop: EventLoop!
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        databaseHelper = DatabaseHelper()
        databaseHelper.db = context.application.db
        eventLoop = context.eventLoop
//        var operations = [EventLoopFuture<Void>]()
//        for country in CountryCodes.all {
//            let op = getAdditionsFuture(country: country).flatMap { () -> EventLoopFuture<Void> in
//                self.getDeletionsFuture(country: country)
//            }
//            operations.append(op)
//        }
//        let allNetflixEvents = EventLoopFuture.andAllComplete(operations, on: eventLoop)
//        let refreshDBJob = RefreshMaterializedViewsJob(databaseHelper: databaseHelper, eventLoop: eventLoop)
//        let exportJob = ExportNetflixJob(databaseHelper: databaseHelper, eventLoop: eventLoop)
//        let genreExportJob = GenreExportJob(eventLoop: eventLoop)
        let findLostJob = FindLostJob(databaseHelper: databaseHelper, eventLoop: eventLoop)
        
//        return allNetflixEvents
//            .flatMap(getTmdbInfoFuture)
//            .flatMap(getOmdbRatingsFuture)
//            .flatMap {
//                self.databaseHelper.removeDoubleQuotes(eventLoop: self.eventLoop)
//            }
//            .flatMap(refreshDBJob.run)
//            .flatMap(exportJob.run)
//            .flatMap(genreExportJob.run)
        return findLostJob.run()
//        return getTmdbInfoFuture()
//            .flatMap(getOmdbRatingsFuture)
//            .flatMap(refreshDBJob.run)
//            .flatMap(exportJob.run)
//            .flatMap(genreExportJob.run)
        
//        return self.databaseHelper.removeDoubleQuotes(eventLoop: self.eventLoop)
//            .flatMap(refreshDBJob.run)
//            .flatMap(exportJob.run)
    }
    
    //MARK: - Private
    
    func getAdditionsFuture(country: CountryCodes) -> EventLoopFuture<Void> {
        return databaseHelper.getFuture(country: country, op: .addition).flatMap { (op) -> EventLoopFuture<Void> in
            guard let diff = self.getUpdateDiff(operation: op),
                  diff > 0 else {
                print("No need for an update in country -> \(op)")
                return self.eventLoop.makeSucceededFuture(())
            }
            let c = NetflixAdditionsFuture(
                databaseHelper: self.databaseHelper,
                eventLoop: self.eventLoop,
                country: country,
                updateDiff: diff
            )
            return c.run()
        }
    }
    
    func getDeletionsFuture(country: CountryCodes) -> EventLoopFuture<Void> {
        return databaseHelper.getFuture(country: country, op: .deletion).flatMap { (op) -> EventLoopFuture<Void> in
            guard let diff = self.getUpdateDiff(operation: op),
                  diff > 0 else {
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
    }
    
    func getTmdbInfoFuture() -> EventLoopFuture<Void> {
        return databaseHelper.getItemsToTMDBEnrichFuture().flatMap { (audiovisuals) -> EventLoopFuture<Void> in
            print(audiovisuals.count)
            let tmdbEnrichEvents = TMDBEnricherFuture(
                audiovisuals: audiovisuals,
                eventLoop: self.eventLoop,
                db: self.databaseHelper.db
            )
            return tmdbEnrichEvents.run()
        }
    }
    
    func getOmdbRatingsFuture() -> EventLoopFuture<Void> {
        return databaseHelper.getItemsWithoutRatingFuture().flatMap { (audiovisuals) -> EventLoopFuture<Void> in
            let omdbRatingEvents = OMDBEnricherFuture(
                audiovisuals: audiovisuals,
                eventLoop: self.eventLoop,
                db: self.databaseHelper.db
            )
            return omdbRatingEvents.run()
        }
    }
    
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
