//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 5/2/21.
//

import Vapor

class NetflixDeletionsFuture {
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
        return databaseHelper.getFuture(country: country, op: .deletion)
            .flatMap(getNetfixDeletions)
            .flatMap(deleteMovies)
            .flatMap { () -> EventLoopFuture<Void> in
                self.databaseHelper.insertOrUpdateFuture(country: self.country, op: .deletion)
            }
    }
    
    //MARK: - Private
    
    private func deleteMovies(_ ids: [String]) -> EventLoopFuture<Void> {
        print("Got ids to delete -> \(ids.count)")
        let bdOps = ids.compactMap {
            self.databaseHelper.deleteFuture(netflixId: $0, country: self.country.rawValue, eventLoop: self.eventLoop)
        }
        return EventLoopFuture.reduce((), bdOps, on: eventLoop) { (accumulated, newValue) -> () in
            return ()
        }
    }
    
    private func getNetfixDeletions(op: OperationPerCountry?) -> EventLoopFuture<[String]> {
        let controller = NetflixUpdateController(country: country, updateDiffDays: updateDiff)
        return controller.getDeletions(eventLoop: eventLoop)
    }
}
