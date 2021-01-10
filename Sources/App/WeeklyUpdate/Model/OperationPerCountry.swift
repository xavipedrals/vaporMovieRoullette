//
//  OperationPerCountry.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 10/1/21.
//

import Foundation
import Fluent

enum NetflixOperation: String {
    case addition = "addition"
    case deletion = "deletion"
}

final class OperationPerCountry: Model {
    static let schema = "netflix_operations"
    
    @ID(custom: "id_auto", generatedBy: .user)
    var id: String? //Auto-generated
    
    @Field(key: "country_id")
    var countryId: String
    
    @Field(key: "operation")
    var operation: String
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(country: CountryCodes, operation: NetflixOperation) {
        id = "\(country.rawValue)_\(operation.rawValue)"
        countryId = country.rawValue
        self.operation = operation.rawValue
    }
}
