//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

//protocol TMDBatchDelegate {
//    func batchFinished(
//        output: Set<EnrichedNetflixMovie>,
//        failures: Set<NetfilxMovie>)
//}
//
//class TMDBatchController: CommonBatch {
//    var group = DispatchGroup()
//    var queue: DispatchQueue
//    var syncQueue: DispatchQueue
//    
//    var countCompleted = 0
//    var input: [NetfilxMovie]
//    
//    var output = Set<EnrichedNetflixMovie>()
//    var failures = Set<NetfilxMovie>()
//    var delegate: TMDBatchDelegate?
//    
//    let service = TMDBService()
//    
//    init(input: [Input], queue: DispatchQueue) {
//        self.input = input
//        self.queue = queue
//        self.syncQueue = DispatchQueue(label: "privateSyncQueue2")
//    }
//    
//    func run() {
//        groupRun()
//    }
//    
//    func doAsyncJob(target: NetfilxMovie) {
//        let safeId = target.imdbId.trimmingCharacters(in: .whitespacesAndNewlines)
//        service.getDetailsFrom(imdbId: safeId) { movie in
//            self.retrieved(obj: movie, original: target)
//        }
//    }
//    
//    func enrich<T>(original: NetfilxMovie, addition: T) -> EnrichedNetflixMovie {
//        guard let addition = addition as? TMDBMovie else { fatalError() }
//        var enrichedMovie = EnrichedNetflixMovie(movie: original)
//        enrichedMovie.enrich(from: addition)
//        return enrichedMovie
//    }
//    
//    func finished() {
//        delegate?.batchFinished(output: output, failures: failures)
//    }
//}
