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
    var currentIndex = -1
    
    init(completion: @escaping (_ success: Bool) -> ()) {
        self.completion = completion
        input = DatabaseHelper.shared.getItemsWithoutRating()
    }
    
    func run() {
        getNextRating()
    }
    
    func moveToNextItem() {
        print("Items left -> \(input.count - currentIndex)")
        currentIndex += 1
        guard currentIndex < input.count else {
            print("Finished with success!")
            completion(true)
            return
        }
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
            let audiovisual = self.input[self.currentIndex]
            audiovisual.combined(with: o)
            DatabaseHelper.shared.update(items: [audiovisual])
        }
    }
}
