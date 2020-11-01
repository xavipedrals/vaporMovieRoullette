//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

struct RateLimit {
    var calls: Int
    var timeInSecs: Int
}

class Commons {
    static func printEstimatedTime(itemsCount: Int, rateLimit: RateLimit) {
        let seconds = itemsCount / rateLimit.calls * (rateLimit.timeInSecs + 2)
        let hours = seconds / 3600
        let minutes = (seconds - (hours * 3600)) / 60
        print("Estimated time: \(hours) hours & \(minutes) minutes")
    }
}

protocol BatchWriter: class {
    var writeFilenamePrefix: String { get }
    var notFoundFilename: String { get }
    var directory: FileDirectory { get }
}

extension BatchWriter {
    func writeBatch<T: Codable>(items: Set<T>, batchIndex: Int) -> Bool {
        guard items.count > 0 else {
            print("Not enough items to write a batch")
            return false
        }
        print("Gonna write batch number -> \(batchIndex)")
        writeToFile(batch: items.map({ $0 }), filename: "\(writeFilenamePrefix)-\(batchIndex).json")
        return true
    }
    
    func writeFailures<T: Codable>(items: Set<T>) {
        guard items.count > 0 else { return }
        writeToFile(batch: items.map({ $0 }), filename: "\(notFoundFilename).json")
    }
    
    private func writeToFile<T: Codable>(batch: [T], filename: String) {
        CustomFileManager.instance.write(array: batch, directory: directory, filename: filename)
    }
}
