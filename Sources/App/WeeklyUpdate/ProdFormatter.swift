//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 30/10/2020.
//

import Foundation

class ProdFormatter {
    var countriesLeft = Set<String>()
    var currentCountry = ""
//    var result = [WeeklyUpdatePerCountry]()
    var allMovies = [CompressedNetflixMovie]()
    
    func run() {
        countriesLeft = Set(CountryCodes.all.compactMap{ $0.rawValue })
//        getAllMovies()
        doNextCountry()
    }
    
    func moveToNextCountry() {
        print("Countries left -> \(countriesLeft.count)")
        guard countriesLeft.count > 0 else {
            print("Finished with success!")
            print("Rewriting all movies with the updates...")
            writeAllUpdatedMovies()
            print("Done! :)")
            exit(0)
        }
        guard let country = countriesLeft.popFirst() else {
            fatalError("Error: Couldn't pop the first country")
        }
        currentCountry = country
    }
    
    func doNextCountry() {
        moveToNextCountry()
//        let moviesToAdd = getMoviesToAdd()
//        let moviesToDelete = getMoviesToDelete() //Netflix Ids
//        updateAllMovies(add: moviesToAdd, delete: moviesToDelete)
        
        
        
//        let countryResult = WeeklyUpdatePerCountry(
//            add: moviesToAdd,
//            delete: moviesToDelete
//        )
//        CustomFileManager.instance.write(
//            obj: countryResult,
//            directory: .prodReady(date: Date()),
//            filename: "\(currentCountry).json")
        doNextCountry()
    }
    
    func updateAllMovies(add: [CompressedNetflixMovie], delete: [String]) {
        for addMovie in add {
            guard let index = allMovies.firstIndex(where: { $0.netflixId == addMovie.netflixId }) else {
                var aux = addMovie
                aux.availableCountries.append(currentCountry)
                allMovies.append(aux)
                continue
            }
            var aux = allMovies[index]
            guard !aux.availableCountries.contains(currentCountry) else { continue }
            aux.availableCountries.append(currentCountry)
            allMovies[index] = aux
        }
        for deleteMovieId in delete {
            guard let index = allMovies.firstIndex(where: { $0.netflixId == deleteMovieId }) else {
                continue
            }
            var aux = allMovies[index]
            guard aux.availableCountries.contains(currentCountry) else { continue }
            aux.availableCountries = aux.availableCountries.filter{ $0 != currentCountry }
            allMovies[index] = aux
        }
    }
    
    func writeAllUpdatedMovies() {
//        let batchSize = 500
//        var i = 0
//        CustomFileManager.instance.deleteAllFiles(in: .prodAllMovies)
//        while i < allMovies.count {
//            var upperBound = i + batchSize
//            if upperBound > allMovies.count { upperBound = allMovies.count }
//            let batch = allMovies[i..<upperBound]
//            writeToFile(batch: Array(batch), filename: "s-clean-tmdb-batch-\(i).json")
//            i += batchSize
//        }
    }
    
    func writeToFile<T: Codable>(batch: [T], filename: String) {
//        CustomFileManager.instance.write(array: batch, directory: .prodAllMovies, filename: filename)
    }
    
    //MARK: - Loading inputs
    
//    func getAllMovies() {
//        let store = NetflixMoviesStore()
//        allMovies = store.getAllMovies()
//    }
//    
//    func getMoviesToDelete() -> [String] {
//        let netflixMovieStore = NetflixMoviesStore()
//        let netflixMovies = netflixMovieStore.getWeeklyUpdatesToDelete(country: currentCountry)
//        return netflixMovies
//    }
//    
//    func getMoviesToAdd() -> [CompressedNetflixMovie] {
//        let rawMoviesToAdd = getInputFor(country: currentCountry)
//        var moviesToAdd = Set<CompressedNetflixMovie>()
//        for (i, movie) in rawMoviesToAdd.enumerated() {
//            moviesToAdd.insert(CompressedNetflixMovie(movie: movie))
//            print("\(i) of \(rawMoviesToAdd.count)")
//        }
//        return moviesToAdd.compactMap { $0 }
//    }
//    
//    func getInputFor(country: String) -> [EnrichedNetflixMovie] {
//        let netflixMovieStore = NetflixMoviesStore()
//        let netflixMovies = netflixMovieStore.getEnrichedWeeklyUpdates(country: country)
//        return netflixMovies
//    }
}
