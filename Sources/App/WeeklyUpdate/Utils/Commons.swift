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
