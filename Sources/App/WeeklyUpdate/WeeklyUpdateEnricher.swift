//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

//class WeeklyUpdateEnricher {
//    
//    var countriesLeft = Set<String>()
//    var currentCountry = ""
////    var resultMap = [String: [EnrichedNetflixMovie]]()
//    
//    func run() {
//        countriesLeft = Set(CompressFinalMovies().supportedCountryCodes)
//        doNextCountry()
//    }
//    
//    func moveToNextCountry() {
//        print("Countries left -> \(countriesLeft.count)")
//        guard countriesLeft.count > 0 else {
//            print("Finished with success!")
//            print("Going to format the weekly updates for production")
//            ProdFormatter().run()
//            exit(0)
//        }
//        guard let country = countriesLeft.popFirst() else {
//            fatalError("Error: Couldn't pop the first country")
//        }
//        currentCountry = country
//    }
//    
//    func doNextCountry() {
//        print("Doing next country")
//        moveToNextCountry()
//        let enricher = TMDBEnricher(
//            input: Set(getInput()),
//            batchIndex: 0,
//            fileNamePrefix: "add-enriched-\(currentCountry)",
//            notFoundName: "notRelevant",
//            directory: .weeklyUpdates)
//        enricher.delegate = self
//        enricher.run()
//    }
//    
//    func getInput() -> [NetfilxMovie] {
//        let netflixMovieStore = NetflixMoviesStore()
//        let netflixMovies = netflixMovieStore.fetchWeeklyNetflixMovies(country: currentCountry)
//        return netflixMovies
//    }
//}
//
//extension WeeklyUpdateEnricher: TMDBEnricherDelegate {
//    func finishedEnriching() {
//        doNextCountry()
//    }
//}
