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
    
//    func getMoviesFor(page: Int, completion: @escaping (NetflixMovieWrapper) -> Void) {
//        let request = UnoGSCurlUrl.getAll(page: page).urlString
//        requestNetflixMovieWrapper(request, completion: completion)
//    }
    
//    func getDetails(netflixId: String, completion: @escaping (DetailsNetflixMovie?) -> Void) {
//        let request = UnoGSCurlUrl.getDetails(netflixId: netflixId).urlString
//        let callback: (NetflixMovieDetailRoot) -> () = { wrapper in
//            completion(wrapper.result)
//        }
//        requestNetflixMovieWrapper(request, completion: callback)
//    }
    
    func getNewAdditions(countryCode: String, since daysBack: Int, completion: @escaping (NetflixMovieWrapper) -> Void) {
        let base = NetflixMovieWrapper(count: "0", movies: [])
        getNewAdditionsRecursive(page: 1, countryCode: countryCode, daysBack: daysBack, base: base, completion: completion)
    }
    
    func getNewDeletions(countryCode: String, since daysBack: Int, completion: @escaping (DeletedNetflixMovieWrapper) -> Void) {
        let request = UnoGSCurlUrl.getNewDeletionsSince(days: daysBack, country: countryCode).urlString
        requestNetflixMovieWrapper(request) { (result: DeletedNetflixMovieWrapper?) in
            guard let r = result else {
                completion(DeletedNetflixMovieWrapper(count: "0", movies: []))
                return
            }
            completion(r)
        }
    }
    
    //MARK: - Private
    
    private func getNewAdditionsRecursive(page: Int, countryCode: String, daysBack: Int, base: NetflixMovieWrapper, completion: @escaping (NetflixMovieWrapper) -> Void) {
        
        let request = UnoGSCurlUrl.getNewAdditionsSince(days: daysBack, country: countryCode, page: page).urlString
        
        requestNetflixMovieWrapper(request) { (result: NetflixMovieWrapper?) in
            guard let r = result else {
                print("ERROR: Could not interpret result")
                completion(base)
                return
            }
            print(r)
            print(r.movies.count)
            let combined = NetflixMovieWrapper.combined(base, r)
            guard !r.isEndPage else {
                print("INFO: Combined is end page")
                completion(combined)
                return
            }
            guard !combined.isComplete else {
                print("INFO: Combined is complete")
                completion(combined)
                return
            }
            self.getNewAdditionsRecursive(
                page: page + 1,
                countryCode: countryCode,
                daysBack: daysBack,
                base: combined,
                completion: completion
            )
        }
    }
    
    private func requestNetflixMovieWrapper<T: Codable>(_ req: String, completion: @escaping (T?) -> Void) {
        let header = "X-RapidAPI-Key: \(apiKey)"
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: [header]) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(T.self, from: data)
                completion(wrapper)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion(nil)
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
