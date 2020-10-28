//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class NetflixMoviesStore: FileStore {
    var fileManager = CustomFileManager.instance
    
    //Needed for 4. Enrich netflix movies (must be saved on batch files)
    
    func fetchBaseNetflixMovies() -> [NetfilxMovie] {
        return fetchAllFiles(withNameFilter: "batch", in: .netflixBaseMovies)
    }
    
    func fetchTMDBEnrichedNetflixMovies() -> [EnrichedNetflixMovie] {
        return fetchAllFiles(withNameFilter: "tmdb-batch", in: .netflixTMDBEnrichedMovies)
    }
    
    func fetchFinalNetflixMovies() -> [EnrichedNetflixMovie] {
        return fetchAllFiles(withNameFilter: "final-batch", in: .netflixFinalMovies)
    }
    
    func fetchNotFoundMovies() -> [NetfilxMovie] {
        return fetchAllFiles(withNameFilter: "tmdbNotFound.json", in: .netflixTMDBEnrichedMovies)
    }
    
    //Needed for 8. Get a weekly update
    
    func fetchWeeklyNetflixMovies(country: String) -> [NetfilxMovie] {
        return fetchAllFiles(withNameFilter: "add-\(country)", in: .weeklyUpdates)
    }
    
    //Needed for 9. Enrich weekly update
    
    func getWeeklyUpdateFailures() -> Int {
        return getNumberForBatchFile(in: .weeklyUpdates, namePart: "batch")
    }
    
    //Needed for 10. Format jsons for prod
    
    func getAllMovies() -> [CompressedNetflixMovie] {
        return fetchAllFiles(withNameFilter: "s-clean-tmdb-batch", in: .prodAllMovies)
    }
    
    func getEnrichedWeeklyUpdates(country: String) -> [EnrichedNetflixMovie] {
        return fetchAllFiles(withNameFilter: "add-enriched-\(country)", in: .weeklyUpdates)
    }
    
    func getWeeklyUpdatesToDelete(country: String) -> [String] {
        return fetchAllFiles(withNameFilter: "delete-\(country)", in: .weeklyUpdates)
    }
    
    //Batch count
    
    func getNetflixTMDBBatchNumber() -> Int {
        return getNumberForBatchFile(in: .netflixTMDBEnrichedMovies, namePart: "batch")
    }
    
    func getFinalNetflixBatchCount() -> Int {
        return getNumberForBatchFile(in: .netflixFinalMovies, namePart: "final-batch")
    }
}
