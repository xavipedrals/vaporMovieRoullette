//
//  UnoGSService.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class UnoGSService {
    
    private var apiKey: String {
        guard let key = UnoGSAPIKeyManager().getKey() else {
            fatalError("All UNOGS keys have been used to the limit")
        }
        return key
    }
    
    func getMoviesFor(page: Int, completion: @escaping (NetflixMovieWrapper) -> Void) {
        let request = UnoGSCurlUrl.getAll(page: page).urlString
        requestNetflixMovieWrapper(request, completion: completion)
    }
    
    func getDetails(netflixId: String, completion: @escaping (DetailsNetflixMovie?) -> Void) {
        
//        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = 10.0
//        sessionConfig.timeoutIntervalForResource = 10.0
//        let session = URLSession(configuration: sessionConfig)
        
        let request = UnoGSCurlUrl.getDetails(netflixId: netflixId).urlString
        let callback: (NetflixMovieDetailRoot) -> () = { wrapper in
            completion(wrapper.result)
        }
        requestNetflixMovieWrapper(request, completion: callback)
//        let task = session.dataTask(with: request) {(data, response, error) in
//            self.printAPILimits(response: response)
//            guard let data = data, error == nil else {
//                print(error ?? "Uh oh, something went wrong getting the data from the HTTP req")
//                completion(nil)
//                return
//            }
//            let result = Parser<NetflixMovieDetailRoot>().parse(data: data)
//            switch result {
//            case .success(let wrapper):
//                completion(wrapper.result)
//            case .failure(let error):
//                print(error)
//                completion(nil)
//            }
//        }
//        task.resume()
    }
    
    func getNewAdditions(countryCode: String, since daysBack: Int, completion: @escaping (NetflixMovieWrapper) -> Void) {
        let request = UnoGSCurlUrl.getNewAdditionsSince(days: daysBack, country: countryCode).urlString
        requestNetflixMovieWrapper(request, completion: completion)
    }
    
    func getNewDeletions(countryCode: String, since daysBack: Int, completion: @escaping (DeletedNetflixMovieWrapper) -> Void) {
        let request = UnoGSCurlUrl.getNewDeletionsSince(days: daysBack, country: countryCode).urlString
        requestNetflixMovieWrapper(request, completion: completion)
    }
    
    private func requestNetflixMovieWrapper<T: Codable>(_ req: String, completion: @escaping (T) -> Void) {
//        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
//            self.printAPILimits(response: response)
//            guard let data = data, error == nil else {
//                print(error ?? "Uh oh, something went wrong getting the data from the HTTP req")
//                return
//            }
//            let result = Parser<T>().parse(data: data)
//            switch result {
//            case .success(let wrapper):
//                completion(wrapper)
//            case .failure(let error):
//                print(error)
//            }
//        }
//        task.resume()
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, apiKey: apiKey) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
            let result = Parser<T>().parse(data: data)
            switch result {
            case .success(let wrapper):
                completion(wrapper)
            case .failure(let error):
                print(error)
            }
        }
    }
    
//    private func printAPILimits(response: URLResponse?) {
//        guard let httpRes = response as? HTTPURLResponse else {
//            return
//        }
//        let headers = httpRes.allHeaderFields
//        guard headers.keys.contains("X-RateLimit-requests-Remaining"),
//            let remaining = headers["X-RateLimit-requests-Remaining"] as? String else {
//                print("Could not know how many requests are left for today")
//                return
//        }
//        print("Remaining requests today -> \(remaining)")
//        guard let count = Int(remaining), count > 0 else { return }
//        UnoGSAPIKeyManager().markLastUsedKeyExhausted()
//    }
}
