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
        countriesLeft = Set(CompressFinalMovies().supportedCountryCodes)
        doNextCountry()
    }
    
    func moveToNextCountry() {
        print("Countries left -> \(countriesLeft.count)")
        guard countriesLeft.count > 0 else {
            print("Finished with success!")
            completion(true)
            return
        }
        guard let country = countriesLeft.popFirst() else {
            print("ERROR: Couldn't pop the first country")
            completion(false)
            return
        }
        currentCountry = country
    }
    
    func doNextCountry() {
        print("Doing next country")
        group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        moveToNextCountry()
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
        service.getNewAdditions(countryCode: currentCountry, since: 7) { (wrapper) in
            let filteredMovies = wrapper.movies.filter{ $0.realType == .movie }
            CustomFileManager.instance.write(
                array: filteredMovies,
                directory: .weeklyUpdates,
                filename: "add-\(self.currentCountry)")
            print("Leaving group 1")
            self.group.leave()
        }
    }
    
    func getNewDeletions() {
        service.getNewDeletions(countryCode: currentCountry, since: 7) { (wrapper) in
            let ids = wrapper.movies.compactMap{ $0.netflixId }
            CustomFileManager.instance.write(
                array: ids,
                directory: .weeklyUpdates,
                filename: "delete-\(self.currentCountry)")
            print("Leaving group 2")
            self.group.leave()
        }
    }
}
