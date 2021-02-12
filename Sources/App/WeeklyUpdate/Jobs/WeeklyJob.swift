//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 13/1/21.
//

import Vapor
import Queues

//class WeeklyJob: ScheduledJob {
//    
//    var completion: () -> ()
//    
//    init(completion: @escaping () -> ()) {
//        self.completion = completion
//    }
//    
//    func run(context: QueueContext) -> EventLoopFuture<Void> {
//        start()
//        return context.eventLoop.makeSucceededFuture(())
//    }
//    
//    func start() {
//        let all = DatabaseHelper.shared.getAllAudioVisuals()
//        TMDBEnricher(input: all).run {
//            self.refreshRatings()
//        }
//    }
//    
//    //MARK: - Private
//    
//    func refreshRatings() {
//        let all = DatabaseHelper.shared.getAllAudioVisuals()
//        OMDBEnricher(input: all, completion: { _ in
//            self.completion()
//        }).run()
//    }
//}
