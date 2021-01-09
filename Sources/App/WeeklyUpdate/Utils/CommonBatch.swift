//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

protocol CommonBatch: class {
    
    associatedtype Input

    var group: DispatchGroup { get set }
    var queue: DispatchQueue { get set }
    var syncQueue: DispatchQueue { get set }
    var countCompleted: Int { get set }
    var input: [Input] { get set }
    
    var output: [Input] { get set }
    
    func enrich<T>(original: Input, addition: T) -> Input
    func doAsyncJob(target: Input)
    func run()
    func finished()
}

extension CommonBatch {
    func retrieved<T>(obj: T?, original: Input) {
        self.countCompleted += 1
        print("Completed -> \(self.countCompleted) of \(self.input.count)")
        guard let aux = obj else {
            print("Failed to retrieve info for \(original)")
            group.leave()
            return
        }
        let result = enrich(original: original, addition: aux)
        //Solved bug segmentation fault when inserting multiple items at the same moment
        let _ = syncQueue.sync {
            output.append(result)
        }
        group.leave()
    }
    
    func groupRun() {
        print("UPPER LIMIT -> \(input.count)")
        for target in input {
            group.enter()
            doAsyncJob(target: target)
        }
        group.notify(queue: queue) {
            self.finished()
        }
    }
}
