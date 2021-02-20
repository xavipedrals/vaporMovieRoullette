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
                completion(nil)
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
    
    func getMovieGenres(completion: @escaping ([Genre]) -> Void) {
        getGenres(type: .getMovieGenres, completion: completion)
    }
    
    func getSeriesGenres(completion: @escaping ([Genre]) -> Void) {
        getGenres(type: .getSeriesGenres, completion: completion)
    }
    
    func getMoviesOfGenre(id: Int, completion: @escaping ([Movie]) -> Void) {
        let req = TMDBCurlUrl.getMoviesBy(genreId: "\(id)").urlString
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: []) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                completion([])
                return
            }
            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(MovieWrapper.self, from: data)
                completion(wrapper.results)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion([])
            }
        }
    }
    
    //MARK: - Private
    
    private func getGenres(type: TMDBCurlUrl, completion: @escaping ([Genre]) -> Void) {
        let req = type.urlString
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: []) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                completion([])
                return
            }
            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(GenreWrapper.self, from: data)
                completion(wrapper.genres)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion([])
            }
        }
    }
}
