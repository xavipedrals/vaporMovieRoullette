//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 10/1/21.
//

import Foundation

class CalendarManager {
    
    var calendar: Calendar

    init() {
        calendar = Calendar(identifier: .gregorian)
        calendar.locale = .autoupdatingCurrent
    }
    
    func getMissingDays(from: Date, to: Date) -> Int {
        let first = calendar.startOfDay(for: from)
        let last = calendar.startOfDay(for: to)
        let components = calendar.dateComponents([.day], from: first, to: last)
        return components.day!
    }
    
}
