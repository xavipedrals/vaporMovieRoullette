//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 01/11/2020.
//

import Foundation

class TMDBService {
    func getDetailsFrom(imdbId: String, completion: @escaping (TMDBMovie?) -> Void) {
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
                completion(wrapper.allItems.first)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion(nil)
            }
        }
    }
}
