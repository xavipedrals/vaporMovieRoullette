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

class RefreshMaterializedViewsJob: ScheduledJob {
    
    var databaseHelper: DatabaseHelper!
    var eventLoop: EventLoop!
    
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        databaseHelper = DatabaseHelper()
        databaseHelper.db = context.application.db
        eventLoop = context.eventLoop
        var event = eventLoop.makeSucceededFuture(())
        for c in CountryCodes.all {
            event = event.flatMap({ () -> EventLoopFuture<Void> in
                self.databaseHelper.generateMaterializedViews(eventLoop: self.eventLoop, country: c)
            })
        }
        return event
    }
}
