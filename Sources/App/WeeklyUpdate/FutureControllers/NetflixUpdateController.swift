//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 5/2/21.
//

import Vapor

//This class makes futures of network operations
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
