//
//  File.swift
//
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

class TMDBEnricher {
    private let rateLimit = RateLimit(calls: 30, timeInSecs: 13)
    var input = [AudioVisual]()
    var currentBatch = [AudioVisual]()
    var group = DispatchGroup()
    let topQueue = DispatchQueue.global(qos: .userInitiated)
    let lowQueue = DispatchQueue.global(qos: .background)
    var lowerBound = 0

    init(input: [AudioVisual]) {
        self.input = input
    }

    func run(completion: @escaping () -> ()) {
        Commons.printEstimatedTime(itemsCount: input.count, rateLimit: rateLimit)
        group.enter()
        topQueue.async {
            self.doNextBatch()
        }
        group.notify(queue: topQueue) {
            print("------------GOT ALL TMDB ENRICHED INFO------------")
            completion()
        }
    }

    func doNextBatch() {
        guard lowerBound < (input.count - 1) else {
            group.leave()
            return
        }
        print("------------REMAINING ITEMS--------------")
        print(input.count)
        var upperBound = lowerBound + rateLimit.calls
        if upperBound > input.count { upperBound = input.count }
        currentBatch = Array(input[lowerBound..<upperBound])
        let batchController = TMDBatchController(input: currentBatch, queue: lowQueue)
        batchController.delegate = self
        batchController.run()
    }
}

extension TMDBEnricher: TMDBatchDelegate {
    func batchFinished(output: [AudioVisual]) {
        DatabaseHelper.shared.update(items: output)
        lowerBound += rateLimit.calls
        doNextBatch()
    }
}
