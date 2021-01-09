//
//  OMDBEnricher.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/1/21.
//

import Foundation

class OMDBEnricher {
    
    var input = [AudioVisual]()
    let service = OMDBService()
    var group = DispatchGroup()
    var completion: (_ success: Bool) -> ()
    var currentIndex = 0
    
    init(completion: @escaping (_ success: Bool) -> ()) {
        self.completion = completion
        input = DatabaseHelper.shared.getItemsWithoutRating()
    }
    
    func run() {
        getNextRating()
    }
    
    func moveToNextItem() {
        print("Items left -> \(input.count - currentIndex)")
        guard currentIndex < input.count else {
            print("Finished with success!")
            completion(true)
            return
        }
        currentIndex += 1
    }
    
    func getNextRating() {
        group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        moveToNextItem()
        group.enter()
        queue.async {
            self.getRating()
        }
        group.notify(queue: .global(qos: .utility)) {
            print("Queue cleared")
            self.getNextRating()
        }
    }
    
    func getRating() {
        guard let imdbId = input[currentIndex].id else {
            self.group.leave()
            return
        }
        service.getDetailsFrom(imdbId: imdbId) { omdbMovie in
            defer { self.group.leave() }
            guard let o = omdbMovie else {
                return
            }
            let audiovisual = self.input[currentIndex]
            audiovisual.combined(with: o)
            DatabaseHelper.shared.update(items: [audiovisual])
        }
        
//        service.getNewAdditions(countryCode: currentCountry, since: 1) { (wrapper) in
//            print("GOT \(wrapper.movies.count) NEW ITEMS TO INSERT")
//            DatabaseHelper.shared.insertOrUpdateNetflix(items: wrapper.movies, country: self.currentCountry)
//            print("Leaving group 1")
//            self.group.leave()
//        }
    }
}
