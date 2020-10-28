//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public class Parser<T: Decodable> {
    
    var dateFormat: JSONDecoder.DateDecodingStrategy?
    
    public init() {}
    
    public func parse(data: Data) -> Result<T> {
        let decoder = getDecoder()
        do {
            let parsedObj = try decoder.decode(T.self, from: data)
            return .success(parsedObj)
        } catch {
            return .failure(error)
        }
    }
    
    private func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if let dateFormat = dateFormat {
            decoder.dateDecodingStrategy = dateFormat
        }
        return decoder
    }
}
