//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

class UnoGSAPIKeyManager {
    private let defaults = [
        UnoGSAPIKeyWithLimit(type: .main, date: Date()),
//        UnoGSAPIKeyWithLimit(type: .second, date: Date()),
//        UnoGSAPIKeyWithLimit(type: .third, date: Date())
    ]
    var savedKeys: [UnoGSAPIKeyWithLimit] {
        get {
            return DefaultsManager().unoGSKeys
        }
        set {
            DefaultsManager().unoGSKeys = newValue
        }
    }
    var lastUsedKey: UnoGSAPIKey?
    
    init() {
        guard savedKeys.count == 0 else {
            savedKeys = updateKeys(date: Date())
            return
        }
        savedKeys = defaults
    }
    
    func getKey() -> String? {
//        return "Pg39B9YjdemshbfsF4A9Zadzn129p19HO7wjsnDtkTLedgooCl"
        return "557617c510msh1b7951ecbeb795ap108561jsnae39c29b0d02"
//        return savedKeys.first?.key
//        savedKeys = updateKeys(date: Date())
//        let target = savedKeys.first{ $0.limit > 0 }
//        savedKeys.removeAll { $0.type == target?.type }
//        guard let afterUse = target?.used() else { return nil }
//        savedKeys.insert(afterUse, at: 0)
//        lastUsedKey = afterUse.type
//        print("Used key -> \(afterUse.key)")
//        print("Limit -> \(afterUse.limit)")
//        return afterUse.key
    }
    
    func markLastUsedKeyExhausted() {
        guard let lastUsedKey = lastUsedKey else { return }
        print("Marking key -> \(lastUsedKey.rawValue) as exhausted")
        let exhaustedKey = UnoGSAPIKeyWithLimit(type: lastUsedKey, date: Date(), limit: 0)
        savedKeys.removeAll { $0.type == lastUsedKey }
        savedKeys.append(exhaustedKey)
    }
    
    private func updateKeys(date: Date) -> [UnoGSAPIKeyWithLimit] {
        return savedKeys.map {
            $0.updated(date: date)
        }
    }
    
}
