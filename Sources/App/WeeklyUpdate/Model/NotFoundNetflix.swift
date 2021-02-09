//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 9/2/21.
//

import Foundation
import Fluent

final class NotFoundNetflix: Model {
    static let schema = "not_found_netflix"
    
    @ID(custom: "netflix_id", generatedBy: .user)
    var id: String? //Auto-generated
    
    @OptionalField(key: "title")
    var title: String?
    
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    init() {}
    
    init(netflixId: String, title: String?) {
        self.id = netflixId
        self.title = title
    }
    
}
