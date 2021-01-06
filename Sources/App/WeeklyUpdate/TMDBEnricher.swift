//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

class TMDBEnricher {
    var filePrefix: String
    var fileNotFound: String
    var fileDirectory: FileDirectory
    
    private let rateLimit = RateLimit(calls: 30, timeInSecs: 13)
    var input: Set<NetfilxMovie>
//    var output = Set<EnrichedNetflixMovie>()
    var failures = Set<NetfilxMovie>()
    
    var currentBatch = [NetfilxMovie]()
    var group = DispatchGroup()
    let topQueue = DispatchQueue.global(qos: .userInitiated)
    let lowQueue = DispatchQueue.global(qos: .background)
    
    var batchIndex: Int = 0
//    var delegate: TMDBEnricherDelegate?
    
    init(input: Set<NetfilxMovie>, batchIndex: Int, fileNamePrefix: String, notFoundName: String, directory: FileDirectory) {
        self.input = input
        self.filePrefix = fileNamePrefix
        self.fileNotFound = notFoundName
        self.batchIndex = batchIndex
        self.fileDirectory = directory
    }
    
    func run() {
        Commons.printEstimatedTime(itemsCount: input.count, rateLimit: rateLimit)
        group.enter()
        topQueue.async {
            self.doNextBatch()
        }
        group.notify(queue: topQueue) {
            print("------------GOT ALL TMDB ENRICHED INFO------------")
            self.writeEnrichedBatch()
//            self.delegate?.finishedEnriching()
        }
    }
    
    func doNextBatch() {
        guard !input.isEmpty else {
            writeEnrichedBatch()
            group.leave()
            return
        }
        print("------------REMAINING ITEMS--------------")
        print(input.count)
        currentBatch = [NetfilxMovie]()
        for _ in 0 ..< rateLimit.calls {
            guard let movie = input.first else { continue }
            currentBatch.append(movie)
            input.remove(movie)
        }
//        let batchController = TMDBatchController(input: currentBatch, queue: lowQueue)
//        batchController.delegate = self
//        batchController.run()
    }
    
    func writeEnrichedBatch() {
//        writeFailures(items: failures)
//        guard writeBatch(items: output, batchIndex: batchIndex) else { return }
//        output.removeAll()
//        batchIndex += 1
    }
}

//extension TMDBEnricher: BatchWriter {
//    var writeFilenamePrefix: String {
//        return filePrefix
//    }
//    var notFoundFilename: String {
//        return fileNotFound
//    }
//    var directory: FileDirectory {
//        return fileDirectory
//    }
//}
//
//extension TMDBEnricher: TMDBatchDelegate {
//    func batchFinished(output: Set<EnrichedNetflixMovie>, failures: Set<NetfilxMovie>) {
//        for movie in output {
//            self.output.insert(movie)
//        }
//        for movie in failures {
//            self.failures.insert(movie)
//        }
//        writeEnrichedBatch()
//        print("Going to sleep for \(rateLimit.timeInSecs) seconds")
//        topQueue.asyncAfter(deadline: .now() + TimeInterval(rateLimit.timeInSecs)) {
//            self.doNextBatch()
//        }
//    }
//}
//
//protocol TMDBEnricherDelegate {
//    func finishedEnriching()
//}
