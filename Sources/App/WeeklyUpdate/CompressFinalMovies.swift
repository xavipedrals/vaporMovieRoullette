//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class CompressFinalMovies {
    let supportedCountryCodes = [
//        "ar", //Argentina
//        "au",
//        "be",
//        "br", //Brazil
//        "ca",
//        "cz", //Czech Republic
//        "fr",
//        "de",
//        "gr", //Greece
//        "hk", //Hong Kong
//        "hu",
//        "is", //Iceland
//        "in",
//        "il", //Israel
//        "it",
//        "jp",
//        "lt", //Lithuania
//        "mx",
//        "nl",
//        "pl",
//        "pt",
//        "ro",
//        "ru",
//        "sg", //Singapore
//        "sk", //Slovakia
//        "za", //South Africa
//        "kr", //Korea
//        "es",
//        "se", //Sweden
//        "ch", //Switzerland
//        "th", //Thailand
//        "gb", //United kingdom
        "us"
    ]
    
//    func run() {
//        let store = NetflixMoviesStore()
//        let finalOnes = store.fetchFinalNetflixMovies()
//        
//        var treatedOnes = Set<CompressedNetflixMovie>()
//        for (i, movie) in finalOnes.enumerated() {
//            treatedOnes.insert(CompressedNetflixMovie(movie: movie))
//            print("\(i) of \(finalOnes.count)")
//        }
//        let toWrite = treatedOnes.compactMap { $0 }
//        let batchSize = 500
//        var i = 0
//        while i < toWrite.count {
//            var upperBound = i + batchSize
//            if upperBound > toWrite.count { upperBound = toWrite.count }
//            let batch = toWrite[i..<upperBound]
//            writeToFile(batch: Array(batch), filename: "s-clean-tmdb-batch-\(i).json")
//            i += batchSize
//        }
//    }
//    
//    func writeToFile<T: Codable>(batch: [T], filename: String) {
//        CustomFileManager.instance.write(array: batch, directory: .netflixFinalCompressedMovies, filename: filename)
//    }
}
