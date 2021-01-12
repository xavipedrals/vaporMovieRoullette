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
        TMDBEnricher().run {
            self.refreshRatings()
        }
    }
    
    func refreshRatings() {
        OMDBEnricher (completion: { _ in
            self.completion()
        }).run()
    }
}
