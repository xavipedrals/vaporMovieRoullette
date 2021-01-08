//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

class TMDBService {
    
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
        
        let req = TMDBCurlUrl.getDetailsFrom(imdbId: imdbId).urlString
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: []) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(TDMMovieWrapper.self, from: data)
                completion(wrapper.results.first)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion(nil)
            }
        }
    }
}
