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
//        var event: EventLoopFuture<Void> = eventLoop.makeSucceededFuture(())
        return databaseHelper.getOldestNotFound().map { (movies) -> () in
            print(movies.first)
            print(movies.last)
            return
        }
//        for c in CountryCodes.all {
//            event = event.flatMap { () -> EventLoopFuture<Void> in
//                self.databaseHelper.getMoviesToExport(eventLoop: self.eventLoop, country: c).map { (movies) -> (Void) in
//                    CustomFileManager.instance.write(array: movies, filename: "netflix_\(c.rawValue).json")
//                }
//            }
//        }
//        return event
    }
}
