//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation
import Vapor

class WeeklyUpdateOption {
    
    var moviesToAdd = Set<NetfilxMovie>()
    var moviesToDelete = Set<String>() //Netflix Ids
    var countriesLeft = Set<CountryCodes>()
    var currentCountry = CountryCodes.argentina //first country
    
    let service = UnoGSService()
    var group = DispatchGroup()
    var completion: (_ success: Bool) -> ()
//    var db: DatabaseHelper
    var calendar: CalendarManager = {
        return CalendarManager()
    }()
    var resultAdditions: [CountryCodes: [NetfilxMovie]] = [:]
    var resultDeletions: [CountryCodes: [String]] = [:]
//    init(db: DatabaseHelper = DatabaseHelper.shared, completion: @escaping (_ success: Bool) -> ()) {
    
    init(completion: @escaping (Bool) -> ()) {
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
        print("I'm alive")
        diff += 1 //This is to ensure no info is lost, repeated updates should not be a problem
        service.getNewAdditions(countryCode: currentCountry.rawValue, since: diff) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO INSERT")
//            self.db.insertOrUpdateNetflix(items: wrapper.movies, country: self.currentCountry.rawValue)
//            self.db.insertOrUpdate(country: self.currentCountry, op: .addition)
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
        print("I'm alive")
        diff += 1 //This is to ensure no info is lost, repeated updates should not be a problem
        service.getNewDeletions(countryCode: currentCountry.rawValue, since: diff) { (wrapper) in
            let ids = wrapper.movies.compactMap{ $0.netflixId }
//            for id in ids {
//                self.db.delete(netflixId: id, country: self.currentCountry.rawValue)
//            }
//            self.db.insertOrUpdate(country: self.currentCountry, op: .deletion)
            print("Leaving deletions group (group 2)")
            self.group.leave()
        }
    }
    
    func getUpdateDiff(operation: NetflixOperation, country: CountryCodes) -> Int? {
        return nil
//        let op = db.get(country: country, op: operation)
//        print("Got something from db")
//        guard let lastUpdate = op?.updatedAt else {
//            print("No date in database")
//            return nil //If there's nothing in the db don't proceed
//        }
//        print("Heloooo")
//        let diff = calendar.getMissingDays(from: lastUpdate, to: Date())
//        print("Difference between updates -> \(diff) days")
//        return diff
    }
}

class NetflixUpdateController {
    
    var country: CountryCodes
    var updateDiffDays: Int
    let service = UnoGSService()
    
    init(country: CountryCodes, updateDiffDays: Int) {
        self.country = country
        self.updateDiffDays = updateDiffDays
    }
    
    func getAdditions(eventLoop: EventLoop) -> EventLoopFuture<[NetfilxMovie]> {
        let promise = eventLoop.makePromise(of: [NetfilxMovie].self)
        getNewAdditions() { movies in
            promise.succeed(movies)
        }
        return promise.futureResult
    }
    
    func getDeletions(eventLoop: EventLoop) -> EventLoopFuture<[String]> {
        let promise = eventLoop.makePromise(of: [String].self)
        getNewDeletions() { ids in
            promise.succeed(ids)
        }
        return promise.futureResult
    }
    
    //MARK: - Private
    
    private func getNewAdditions(completion: @escaping ([NetfilxMovie]) -> ()) {
        service.getNewAdditions(countryCode: country.rawValue, since: updateDiffDays) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO INSERT")
            completion(wrapper.movies)
        }
    }
    
    private func getNewDeletions(completion: @escaping ([String]) -> ()) {
        service.getNewDeletions(countryCode: country.rawValue, since: updateDiffDays) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO DELETE")
            completion(wrapper.movies.compactMap{ $0.netflixId })
        }
    }

}

class NetflixDeletionsUpdateController {

    var country: CountryCodes
    var updateDiffDays: Int
    let service = UnoGSService()

    init(country: CountryCodes, updateDiffDays: Int) {
        self.country = country
        self.updateDiffDays = updateDiffDays
    }

    func run(eventLoop: EventLoop) -> EventLoopFuture<[String]> {
        let promise = eventLoop.makePromise(of: [String].self)
        getNewDeletions() { ids in
            promise.succeed(ids)
        }
        return promise.futureResult
    }

    func getNewDeletions(completion: @escaping ([String]) -> ()) {
        service.getNewDeletions(countryCode: country.rawValue, since: updateDiffDays) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO DELETE")
            completion(wrapper.movies.compactMap{ $0.netflixId })
        }
    }

}
