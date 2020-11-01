//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

struct WeeklyUpdatePerCountry: Codable {
    var add: [CompressedNetflixMovie]
    var delete: [String]
}
