//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 10/1/21.
//

import Foundation

class DailyJob {
    
    var completion: () -> ()
    
    init(completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    func run() {
        WeeklyUpdateOption(completion: { _ in
            self.refreshTMDBInfo()
        }).run()
    }
    
    //MARK: - Private
    
    func refreshTMDBInfo() {
        TMDBEnricher().run {
            self.refreshRatings()
        }
    }
    
    func refreshRatings() {
        OMDBEnricher (completion: { _ in
            self.completion()
        }).run()
    }
}
