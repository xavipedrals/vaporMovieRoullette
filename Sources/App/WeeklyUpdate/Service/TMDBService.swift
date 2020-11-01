//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

class TMDBService {
    
//    var session: URLSession
    
    init() {
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 10.0
//        sessionConfig.timeoutIntervalForResource = 10.0
//        session = URLSession(configuration: sessionConfig)
    }
    
    func getMovieDetails(id: String, lang: String, completion: @escaping (MinifiedMovie) -> Void) {
//        let task = URLSession.shared.dataTask(with: TMDBRouter.getDetails(id: id, lang: lang).urlRequest) {(data, response, error) in
//            guard let data = data else { return }
//            let result = Parser<MinifiedMovie>().parse(data: data)
//            switch result {
//            case .success(let movie):
//                completion(movie)
//            case .failure(let error):
//                print(error)
//            }
//        }
//        task.resume()
    }
    
    func getDetailsFrom(imdbId: String, completion: @escaping (TMDBMovie?) -> Void) {
//        print("Getting details for -> \(imdbId)")
//        let request = TMDBRouter.getDetailsFrom(imdbId: imdbId).urlRequest
//        let task = session.dataTask(with: request) { data, response, error in
//            guard error == nil else {
//                print(error)
//                completion(nil)
//                return
//            }
//            guard let data = data else {
//                completion(nil)
//                return
//            }
//            let result = Parser<TDMMovieWrapper>().parse(data: data)
//            switch result {
//            case .success(let wrapper):
//                guard let movie = wrapper.results.first else {
//                    print("ERROR: MOVIE NOT FOOOOOOOOOOOOOOOOOOUND")
//                    completion(nil)
//                    return
//                }
//                completion(movie)
//            case .failure(let error):
//                print(error)
//                completion(nil)
//            }
//        }
//        task.resume()
    }
}
