//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

enum UnoGSAPIKey: String, Codable {
    case main = "557617c510msh1b7951ecbeb795ap108561jsnae39c29b0d02" //simple.beautiful.apps
    case second = "Pg39B9YjdemshbfsF4A9Zadzn129p19HO7wjsnDtkTLedgooCl" //xavi.pedrals
//    case third = "sida"
}

struct UnoGSAPIKeyWithLimit: Codable {
    var type: UnoGSAPIKey
    var limit: Int
    var date: Date
    var key: String {
        return type.rawValue
    }
    
    init(type: UnoGSAPIKey, date: Date, limit: Int = 100) {
        self.type = type
        self.date = date
        self.limit = limit
    }
    
    func updated(date newDate: Date) -> UnoGSAPIKeyWithLimit {
        let dayInSecs: TimeInterval = 3600 * 24
        guard newDate.timeIntervalSince(date) > dayInSecs else {
            return self
        }
        return UnoGSAPIKeyWithLimit(type: type, date: date)
    }
    
    func used() -> UnoGSAPIKeyWithLimit {
        return UnoGSAPIKeyWithLimit(type: type, date: date, limit: limit - 1)
    }
}
