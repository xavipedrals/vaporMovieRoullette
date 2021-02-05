//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 5/2/21.
//

import Vapor

class NetflixAdditionsFuture {
    var databaseHelper: DatabaseHelper
    var eventLoop: EventLoop
    var country: CountryCodes
    var updateDiff: Int
    
    init(databaseHelper: DatabaseHelper, eventLoop: EventLoop, country: CountryCodes, updateDiff: Int) {
        self.databaseHelper = databaseHelper
        self.eventLoop = eventLoop
        self.country = country
        self.updateDiff = updateDiff
    }
    
    func run() -> EventLoopFuture<Void> {
        return databaseHelper.getFuture(country: country, op: .addition)
            .flatMap(getNetfixAdditions)
            .flatMap(saveMovies)
            .flatMap { () -> EventLoopFuture<Void> in
                self.databaseHelper.insertOrUpdateFuture(country: self.country, op: .addition)
            }
    }
    
    //MARK: - Private
    
    private func saveMovies(_ movies: [NetfilxMovie]) -> EventLoopFuture<Void> {
        print("Got movies -> \(movies.count)")
        let bdOps = databaseHelper.insertOrUpdateNetflixFuture(items: movies, country: country.rawValue)
        return EventLoopFuture.reduce((), bdOps, on: eventLoop) { (accumulated, newValue) -> () in
            return ()
        }
    }
    
    private func getNetfixAdditions(op: OperationPerCountry?) -> EventLoopFuture<[NetfilxMovie]> {
        let controller = NetflixUpdateController(country: country, updateDiffDays: updateDiff)
        return controller.getAdditions(eventLoop: eventLoop)
    }
}
