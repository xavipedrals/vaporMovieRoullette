//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

protocol TMDBatchDelegate {
    func batchFinished(output: [AudioVisual])
}

class TMDBatchController: CommonBatch {
    var group = DispatchGroup()
    var queue: DispatchQueue
    var syncQueue: DispatchQueue
    var countCompleted = 0
    var input: [AudioVisual]
    var output = [AudioVisual]()
    var delegate: TMDBatchDelegate?
    let service = TMDBService()
    
    init(input: [AudioVisual], queue: DispatchQueue) {
        self.input = input
        self.queue = queue
        self.syncQueue = DispatchQueue(label: "privateSyncQueue2")
    }
    
    func run() {
        groupRun()
    }
    
    func doAsyncJob(target: AudioVisual) {
        guard let safeId = target.id?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        service.getDetailsFrom(imdbId: safeId) { movie in
            self.retrieved(obj: movie, original: target)
        }
    }
    
    func enrich<T>(original: AudioVisual, addition: T) -> AudioVisual {
        guard let addition = addition as? TMDBMovie else { fatalError() }
        original.combined(with: addition)
        return original
    }
    
    func finished() {
        delegate?.batchFinished(output: output)
    }
}
