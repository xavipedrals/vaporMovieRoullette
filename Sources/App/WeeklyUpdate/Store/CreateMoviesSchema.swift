//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 6/1/21.
//

import Fluent

//Migrations only run once: Once they run in a database, they never execute again. So, Fluent won’t attempt to recreate a table if you change the migration.
struct CreateMoviesSchema: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("audiovisuals")
            .field("imdb_id", .string, .identifier(auto: false))
            .field("netflix_id", .string, .required)
            .field("tmdb_id", .string)
            .field("title", .string)
            .field("netflix_rating", .double)
            .field("tmdb_rating", .double)
            .field("imdb_rating", .double)
            .field("rotten_tomatoes_rating", .double)
            .field("available_countries", .array(of: .string))
            .field("genres", .array(of: .int))
            .field("release_year", .int)
            .field("type", .string)
            .field("duration", .string)
            .create()
    }
        
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("audiovisuals").delete()
    }
}
