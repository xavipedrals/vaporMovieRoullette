//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 13/2/21.
//

import Vapor
import Queues
import Fluent
import FluentPostgresDriver

class RefreshMaterializedViewsJob {
    
    var databaseHelper: DatabaseHelper!
    var eventLoop: EventLoop!
    
    init(databaseHelper: DatabaseHelper, eventLoop: EventLoop) {
        self.databaseHelper = databaseHelper
        self.eventLoop = eventLoop
    }
    
    func run() -> EventLoopFuture<Void> {
        var event = eventLoop.makeSucceededFuture(())
        for c in CountryCodes.all {
            event = event.flatMap({ () -> EventLoopFuture<Void> in
                self.databaseHelper.generateMaterializedViews(eventLoop: self.eventLoop, country: c)
            })
        }
        return event
    }
}
