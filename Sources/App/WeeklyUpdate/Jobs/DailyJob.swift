//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 10/1/21.
//

import Vapor
import Queues

class DailyJob: ScheduledJob {
    
    var completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
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
        let itemsToEnrich = DatabaseHelper.shared.getItemsToTMDBEnrich()
        TMDBEnricher(input: itemsToEnrich).run {
            self.refreshRatings()
        }
    }
    
    func refreshRatings() {
        let noRatingItems = DatabaseHelper.shared.getItemsWithoutRating()
        OMDBEnricher(input: noRatingItems, completion: { _ in
            self.completion()
        }).run()
    }
}


class RecoveryDailyJob: ScheduledJob {
    
    var completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        start()
        return context.eventLoop.makeSucceededFuture(())
    }
    
    func start() {
        guard let n = getUpdateDiff(operation: .addition, country: .argentina),
              n > 0 else {
            print("No need for a recovery daily job")
            return
        }
        WeeklyUpdateOption(completion: { _ in
            self.refreshTMDBInfo()
        }).run()
    }
    
    //MARK: - Private
    
    func getUpdateDiff(operation: NetflixOperation, country: CountryCodes) -> Int? {
        let op = DatabaseHelper.shared.get(country: country, op: operation)
        guard let lastUpdate = op?.updatedAt else {
            print("No date in database")
            return nil //If there's nothing in the db don't proceed
        }
        let diff = CalendarManager().getMissingDays(from: lastUpdate, to: Date())
        print("Difference between updates -> \(diff) days")
        return diff
    }
    
    func refreshTMDBInfo() {
        let itemsToEnrich = DatabaseHelper.shared.getItemsToTMDBEnrich()
        TMDBEnricher(input: itemsToEnrich).run {
            self.refreshRatings()
        }
    }
    
    func refreshRatings() {
        let noRatingItems = DatabaseHelper.shared.getItemsWithoutRating()
        OMDBEnricher(input: noRatingItems, completion: { _ in
            self.completion()
        }).run()
    }
}
