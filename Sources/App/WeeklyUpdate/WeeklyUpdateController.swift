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
    var countriesLeft = Set<String>()
    var currentCountry = ""
    
    let service = UnoGSService()
    var group = DispatchGroup()
    var completion: (_ success: Bool) -> ()
    
    init(completion: @escaping (_ success: Bool) -> ()) {
        self.completion = completion
    }
    
    func run() {
        countriesLeft = Set(CountryCodes.all.compactMap{ $0.rawValue })
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
        //TODO: Save in files the last update date per country
        service.getNewAdditions(countryCode: currentCountry, since: 90) { (wrapper) in
            print("GOT \(wrapper.movies.count) NEW ITEMS TO INSERT")
            DatabaseHelper.shared.insertOrUpdateNetflix(items: wrapper.movies, country: self.currentCountry)
            print("Leaving group 1")
            self.group.leave()
        }
    }
    
    func getNewDeletions() {
//        service.getNewDeletions(countryCode: currentCountry, since: 7) { (wrapper) in
//            let ids = wrapper.movies.compactMap{ $0.netflixId }
//            for id in ids {
//                DatabaseHelper.shared.delete(netflixId: id, country: self.currentCountry)
//            }
            print("Leaving group 2")
            self.group.leave()
//        }
    }
}
