//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/1/21.
//

import Foundation

class OMDBService {
    func getDetailsFrom(imdbId: String, completion: @escaping (OMDBMovie?) -> Void) {
        let req = OMDBCurlUrl.getDetail(imdbId: imdbId).urlString
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: []) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(OMDBMovie.self, from: data)
                completion(wrapper)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion(nil)
            }
        }
    }
}
