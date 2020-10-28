//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class DefaultsManager {
    
    private let unoGSKeysKey = "movieListsLastGenreSync"
    private let defaults = UserDefaults.standard
    
    var unoGSKeys: [UnoGSAPIKeyWithLimit] {
        get {
            guard let data = defaults.data(forKey: unoGSKeysKey) else { return [] }
            let decoded = try? JSONDecoder().decode([UnoGSAPIKeyWithLimit].self, from: data)
            return decoded ?? []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: unoGSKeysKey)
        }
    }
    
    func cleanDefaults() {
        defaults.dictionaryRepresentation().keys.forEach { defaults.removeObject(forKey: $0)
        }
    }
}
