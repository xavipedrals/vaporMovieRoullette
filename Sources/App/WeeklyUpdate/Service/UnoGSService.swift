//
//  UnoGSService.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class UnoGSService {
    
    private var additionApiKey: String {
        return "557617c510msh1b7951ecbeb795ap108561jsnae39c29b0d02" //SBA
    }

    private var deletionApiKey: String {
        return "Pg39B9YjdemshbfsF4A9Zadzn129p19HO7wjsnDtkTLedgooCl" //xavi.pedrals
    }
    
    func getNewAdditions(countryCode: String, since daysBack: Int, completion: @escaping (NetflixMovieWrapper) -> Void) {
        let base = NetflixMovieWrapper(count: "0", movies: [])
        getNewAdditionsRecursive(page: 1, countryCode: countryCode, daysBack: daysBack, base: base, completion: completion)
    }
    
    func getNewDeletions(countryCode: String, since daysBack: Int, completion: @escaping (DeletedNetflixMovieWrapper) -> Void) {
        let request = UnoGSCurlUrl.getNewDeletionsSince(days: daysBack, country: countryCode).urlString
        requestNetflixMovieWrapper(request, apiKey: deletionApiKey) { (result: DeletedNetflixMovieWrapper?) in
            guard let r = result else {
                completion(DeletedNetflixMovieWrapper(count: "0", movies: []))
                return
            }
            completion(r)
        }
    }
    
    func getDetailsFor(netflixId: String, useAddittionKey: Bool = true, completion: @escaping (NetflixDetails?) -> ()) {
        let request = UnoGSCurlUrl.getDetails(netflixId: netflixId).urlString
        let header = "X-RapidAPI-Key: \(useAddittionKey ? additionApiKey : deletionApiKey)"
        let helper = CCurlHelper()
        helper.doRequest(endpoint: request, headers: [header]) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
//            print(data.toString())
            do {
                let wrapper = try JSONDecoder().decode(NetflixDetailsWrapper.self, from: data)
                completion(wrapper.item)
            } catch {
                print(error)
                print("DATA ERROR")
                print(data.toString())
                completion(nil)
            }
        }
    }
    
    //MARK: - Private
    
    private func getNewAdditionsRecursive(page: Int, countryCode: String, daysBack: Int, base: NetflixMovieWrapper, completion: @escaping (NetflixMovieWrapper) -> Void) {
        
        let request = UnoGSCurlUrl.getNewAdditionsSince(days: daysBack, country: countryCode, page: page).urlString
        
        requestNetflixMovieWrapper(request, apiKey: additionApiKey) { (result: NetflixMovieWrapper?) in
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
    
    private func requestNetflixMovieWrapper<T: Codable>(_ req: String, apiKey: String, completion: @escaping (T?) -> Void) {
        let header = "X-RapidAPI-Key: \(apiKey)"
        let helper = CCurlHelper()
        helper.doRequest(endpoint: req, headers: [header]) { data in
            guard let data = data else {
                print("Uh oh, something went wrong getting the data from the HTTP req")
                return
            }
//            print(data.toString())
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
