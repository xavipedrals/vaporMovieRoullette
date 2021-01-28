//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class WeeklyUpdateOption {
    
    var moviesToAdd = Set<NetfilxMovie>()
    var moviesToDelete = Set<String>() //Netflix Ids
    var countriesLeft = Set<CountryCodes>()
    var currentCountry = CountryCodes.argentina //first country
    
    let service = UnoGSService()
    var group = DispatchGroup()
    var completion: (_ success: Bool) -> ()
    var db: DatabaseHelper
    var calendar: CalendarManager = {
        return CalendarManager()
    }()
    
    init(db: DatabaseHelper = DatabaseHelper.shared, completion: @escaping (_ success: Bool) -> ()) {
        self.db = db
        self.completion = completion
    }
    
    func run() {
        countriesLeft = Set(CountryCodes.all)
        doNextCountry()
    }
    
    func canMoveToNextCountry() -> Bool {
        print("Countries left -> \(countriesLeft.count)")
        guard countriesLeft.count > 0 else {
            print("Finished with success!")
            completion(true)
            return false
        }
        guard let country = countriesLeft.popFirst() else {
            print("ERROR: Couldn't pop the first country")
            completion(false)
            return false
        }
        currentCountry = country
        return true
    }
    
    func doNextCountry() {
        print("Doing next country")
        group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        guard canMoveToNextCountry() else { return }
        group.enter()
        queue.async {
            self.getNewAdditions()
        }
        group.enter()
        queue.async {
            self.getNewDeletions()
        }
        group.notify(queue: .global(qos: .utility)) {
            print("Queue cleared")
            self.doNextCountry()
        }
    }
    
    func getNewAdditions() {
        guard var diff = getUpdateDiff(operation: .addition, country: currentCountry),
              diff > 0,
              diff < 7 else {
            print("Info: Either last update was today or longer than 7 days, skipping add")
            self.group.leave()
            return
        }
        diff += 1 //This is to ensure no info is lost, repeated updates should not be a problem
        service.getNewAdditions(countryCode: currentCountry.rawValue, since: diff) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO INSERT")
            self.db.insertOrUpdateNetflix(items: wrapper.movies, country: self.currentCountry.rawValue)
            self.db.insertOrUpdate(country: self.currentCountry, op: .addition)
            print("Leaving additions group (group 1)")
            self.group.leave()
        }
    }
    
    func getNewDeletions() {
        guard var diff = getUpdateDiff(operation: .deletion, country: currentCountry),
              diff > 0,
              diff < 7 else {
            print("Info: Either last update was today or longer than 7 days, skipping delete")
            self.group.leave()
            return
        }
        diff += 1 //This is to ensure no info is lost, repeated updates should not be a problem
        service.getNewDeletions(countryCode: currentCountry.rawValue, since: diff) { (wrapper) in
            let ids = wrapper.movies.compactMap{ $0.netflixId }
            for id in ids {
                self.db.delete(netflixId: id, country: self.currentCountry.rawValue)
            }
            self.db.insertOrUpdate(country: self.currentCountry, op: .deletion)
            print("Leaving deletions group (group 2)")
            self.group.leave()
        }
    }
    
    func getUpdateDiff(operation: NetflixOperation, country: CountryCodes) -> Int? {
        let op = db.get(country: country, op: operation)
        guard let lastUpdate = op?.updatedAt else {
            print("No date in database")
            return nil //If there's nothing in the db don't proceed
        }
        let diff = calendar.getMissingDays(from: lastUpdate, to: Date())
        print("Difference between updates -> \(diff) days")
        return diff
    }
}
