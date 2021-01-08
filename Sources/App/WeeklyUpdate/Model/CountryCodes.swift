//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

enum CountryCodes: String {
    case argentina = "ar"
    case australia = "au"
//    case "be",
    case brazil = "br"
//    case "ca",
    case czechRepublic = "cz"
    case france = "fr"
//    case "de",
    case greece = "gr"
    case hongKong = "hk"
//    case "hu",
    case iceland = "is"
//    case "in",
    case israel = "il"
    case italia = "it"
    case japan = "jp"
    case lithuania = "lt"
    case mexico = "mx"
    case netherlands = "nl"
//    case "pl",
    case portugal = "pt"
    case romania = "ro"
    case russia = "ru"
    case singapore = "sg"
    case slovakia = "sk"
    case southAfrica = "za"
    case korea = "kr"
    case spain = "es"
    case sweden = "se"
    case switzerland = "ch"
    case thailand = "th"
    case unitedKingdom = "gb"
    case unitedStates = "us"
    
    static let all: [CountryCodes] = [
//        .argentina,
//        .australia,
//    case "be",
//        .brazil,
//    case "ca",
//        .czechRepublic,
//        .france,
//    case "de",
//        .greece,
//        .hongKong,
//    case "hu",
//        .iceland,
//    case "in",
//        .israel,
//        .italia,
//        .japan,
//        .lithuania,
//        .mexico,
//        .netherlands,
//    case "pl",
//        .portugal,
//        .romania,
//        .russia,
//        .singapore,
//        .slovakia,
//        .southAfrica,
//        .korea,
        .spain,
//        .sweden,
//        .switzerland,
//        .thailand,
        .unitedKingdom,
        .unitedStates
    ]
}


//class CompressFinalMovies {
//    let supportedCountryCodes = [
//        "ar", //Argentina
//        "au", //Australia
//        "be",
//        "br", //Brazil
//        "ca",
//        "cz", //Czech Republic
//        "fr", //France
//        "de",
//        "gr", //Greece
//        "hk", //Hong Kong
//        "hu",
//        "is", //Iceland
//        "in",
//        "il", //Israel
//        "it", //Italia
//        "jp", //Japan
//        "lt", //Lithuania
//        "mx", //Mexico
//        "nl", //Netherlands
//        "pl",
//        "pt", //Portugal
//        "ro", //Romania
//        "ru", //Russia
//        "sg", //Singapore
//        "sk", //Slovakia
//        "za", //South Africa
//        "kr", //Korea
//        "es", //Spain
//        "se", //Sweden
//        "ch", //Switzerland
//        "th", //Thailand
//        "gb", //United kingdom
//        "us"
//    ]
    
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
//}