//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Vapor
import Fluent
import FluentPostgresDriver

class DatabaseHelper {
    static let shared = DatabaseHelper()
    var db: Database!
    
    //Try to call this from the custom scheduled workers
    init() {}
    
    //MARK: - Public
    
    func insertOrUpdateNetflix(items: [NetfilxMovie], country: String) {
        let audiovisuals = items.compactMap { AudioVisual(item: $0) }
        for a in audiovisuals {
            do {
                let dbItem = try AudioVisual.find(a.id, on: db).wait()
                insertOrUpdate(dbItem: dbItem, newItem: a, country: country)
            } catch {
                print(error)
            }
        }
    }
    
    func insertOrUpdateNetflixFuture(items: [NetfilxMovie], country: String) -> [EventLoopFuture<Void>] {
        let audiovisuals = items.compactMap { AudioVisual(item: $0) }
        let audiovisualOps = audiovisuals.compactMap { (a) -> EventLoopFuture<Void> in
            AudioVisual.find(a.id, on: db).flatMap { (av) -> EventLoopFuture<Void> in
                self.insertOrUpdateFuture(dbItem: av, newItem: a, country: country)
            }
        }
        let notFoundOps = items.filter {
            $0.imdbId == nil || $0.imdbId == "" || $0.imdbId == " "
        }.compactMap {
            NotFoundNetflix(netflixId: $0.netflixId, title: $0.title)
        }.compactMap { (n) -> EventLoopFuture<Void> in
            NotFoundNetflix.find(n.id, on: db).flatMap { (dbItem) -> EventLoopFuture<Void> in
                self.insertOrUpdateFuture(dbItem: dbItem, newItem: n)
            }
        }
        return audiovisualOps + notFoundOps
    }
    
    func delete(netflixId: String, country: String) {
        do {
            let item = try AudioVisual.query(on: db)
                .filter(\.$netflixId == netflixId)
                .first()
                .wait()
            guard let i = item else {
                print("Movie with netflixId \(netflixId) not found, ignoring delete")
                return
            }
            i.remove(country: country)
            guard i.availableCountries.count > 0 else {
                print("Deleting all record from movie with netflixId -> \(netflixId)")
                try? i.delete(force: true, on: db).wait()
                return
            }
            print("Removing country \(country) from movie with netflixId \(netflixId)")
            save(i)
        } catch {
            print(error)
        }
    }
    
    func deleteFuture(netflixId: String, country: String, eventLoop: EventLoop) -> EventLoopFuture<Void> {
        return AudioVisual.query(on: db)
            .filter(\.$netflixId == netflixId)
            .first()
            .flatMap { (av) -> EventLoopFuture<Void> in
                guard let audiovisual = av else {
                    print("Can't delete item with netflixId -> \(netflixId), not found")
                    return eventLoop.makeSucceededFuture(())
                }
                print("Deleting item with netflixId -> \(audiovisual.netflixId)")
                audiovisual.remove(country: country)
                guard audiovisual.availableCountries.count > 0 else {
                    print("Deleting all record from movie with netflixId -> \(netflixId)")
                    return audiovisual.delete(force: true, on: self.db)
                }
                return audiovisual.save(on: self.db)
            }
    }
    
    func getItemsToTMDBEnrich() -> [AudioVisual] {
        let audiovisualsToEnrich = try? AudioVisual.query(on: db)
            .filter(\.$tmdbId == nil)
            .all()
            .wait()
        return audiovisualsToEnrich ?? []
    }
    
    func getItemsToTMDBEnrichFuture() -> EventLoopFuture<[AudioVisual]> {
        return AudioVisual.query(on: db)
            .filter(\.$tmdbId == nil)
            .all()
    }
    
    func getAllAudioVisuals() -> [AudioVisual] {
        let audiovisualsToEnrich = try? AudioVisual.query(on: db)
            .all()
            .wait()
        return audiovisualsToEnrich ?? []
    }
    
    func update(items: [AudioVisual]) {
        for item in items {
            save(item)
        }
    }
    
    func getItemsWithoutRating() -> [AudioVisual] {
        let audiovisualsWithoutRating = try? AudioVisual.query(on: db)
            .filter(\.$rottenTomatoesRating == nil)
            .all()
            .wait()
        return audiovisualsWithoutRating ?? []
    }
    
    func getItemsWithoutRatingFuture() -> EventLoopFuture<[AudioVisual]> {
        return AudioVisual.query(on: db)
            .filter(\.$rottenTomatoesRating == nil)
            .all()
    }
    
    func insertOrUpdate(country: CountryCodes, op: NetflixOperation) {
        guard let dbOp = get(country: country, op: op) else {
            let operation = OperationPerCountry(country: country, operation: op)
            save(operation)
            return
        }
        //This change does nothing except updating the timestamp
        dbOp.operation = op.rawValue
        save(dbOp)
    }
    
    func insertOrUpdateFuture(country: CountryCodes, op: NetflixOperation) -> EventLoopFuture<Void> {
        return getFuture(country: country, op: op).flatMap { [self] (dbOperation) -> EventLoopFuture<Void> in
            guard let dbOperation = dbOperation else {
                let operation = OperationPerCountry(country: country, operation: op)
                return operation.save(on: self.db)
                
            }
            //This change does nothing except updating the timestamp
            dbOperation.operation = op.rawValue
            return dbOperation.save(on: self.db)
        }
    }
    
    func insertOrUpdate23(operation: OperationPerCountry) {
        guard let dbItem = try? OperationPerCountry.find(operation.id, on: db).wait() else {
            save(operation)
            return
        }
        //This change does nothing except updating the timestamp
        dbItem.operation = operation.operation
        save(dbItem)
    }
    
    func get(country: CountryCodes, op: NetflixOperation) -> OperationPerCountry? {
        let id = OperationPerCountry.getId(country, op)
        print("Operation id -> \(id)")
        do {
            return try OperationPerCountry.find(id, on: db).wait()
        } catch {
            print(error)
            return nil
        }
    }
    
    func getFuture(country: CountryCodes, op: NetflixOperation) -> EventLoopFuture<OperationPerCountry?> {
        let id = OperationPerCountry.getId(country, op)
        print("Operation id -> \(id)")
        return OperationPerCountry.find(id, on: db)
    }
    
    func generateMaterializedViews(eventLoop: EventLoop, country: CountryCodes) -> EventLoopFuture<Void> {
        print("Trying to refresh materialized view \(country)")
        guard let database = db as? PostgresDatabase else {
            print("Can't cast PostgresDatabase")
            return eventLoop.makeSucceededFuture(())
        }
        return database.query("REFRESH MATERIALIZED VIEW netflix_\(country.rawValue)").map { _ -> Void in
            print("Refreshed materialized view \(country)")
            return
        }
    }
    
    func getMoviesToExport(eventLoop: EventLoop, country: CountryCodes) -> EventLoopFuture<[ExportMovie]> {
        guard let database = db as? SQLDatabase else {
            print("Error: Could not parse database to SQLDatabase")
            return eventLoop.makeSucceededFuture([])
        }
        return database.raw("""
        SELECT imdb_id, netflix_id, tmdb_id, title, type, genres, release_year, duration, netflix_rating, imdb_rating, tmdb_rating, rotten_tomatoes_rating, metacritic_rating
            FROM netflix_\(country.rawValue)
        """).all().map { (rows) -> ([ExportMovie]) in
                print("GOT \(rows.count) ROWS TO EXPORT")
                return rows.compactMap{ try? $0.decode(model: ExportMovie.self) }
        }
    }
    
    func getOldestNotFound() -> EventLoopFuture<[NotFoundNetflix]> {
        return NotFoundNetflix.query(on: db).sort(\.$updatedAt).all()
    }
    
    func update(notFound: NotFoundNetflix) -> EventLoopFuture<Void> {
        return NotFoundNetflix.find(notFound.id, on: db).flatMap { (dbItem) -> EventLoopFuture<Void> in
            return self.insertOrUpdateFuture(dbItem: dbItem, newItem: notFound)
        }
    }
    
    func removeDoubleQuotes(eventLoop: EventLoop) -> EventLoopFuture<Void> {
        guard let database = db as? SQLDatabase else {
            print("Error: Could not parse database to SQLDatabase")
            return eventLoop.makeSucceededFuture(())
        }
        return database.raw("""
        UPDATE audiovisuals SET title = regexp_replace(title, '"', '', 'gi');
        """).run()
    }
    
    //MARK: - Private
    
    private func insertOrUpdate(dbItem: AudioVisual?, newItem: AudioVisual, country: String) {
        guard let dbItem = dbItem else {
            print("INSERTING NEW ITEM WITH IMDB \(newItem.id)")
            newItem.add(country: country)
            save(newItem)
            return
        }
        dbItem.combined(with: newItem, country: country)
        print("UPDATING EXISTING ITEM WITH IMDB \(newItem.id)")
        save(dbItem)
    }
    
    private func insertOrUpdateFuture(dbItem: AudioVisual?, newItem: AudioVisual, country: String) -> EventLoopFuture<Void> {
        guard let dbItem = dbItem else {
            print("DB: INSERTING NEW ITEM WITH IMDB \(newItem.id)")
            newItem.add(country: country)
            return newItem.save(on: db)
        }
        print("DB: UPDATING ITEM WITH IMDB \(newItem.id)")
        dbItem.combined(with: newItem, country: country)
        return dbItem.save(on: db)
    }
    
    private func insertOrUpdateFuture(dbItem: NotFoundNetflix?, newItem: NotFoundNetflix) -> EventLoopFuture<Void> {
        guard let dbItem = dbItem else {
            print("DB: INSERTING NOT FOUND ITEM WITH NETFLIXID \(newItem.id)")
            return newItem.save(on: db)
        }
        print("DB: UPDATING NOT FOUND ITEM WITH NETFLIXID \(newItem.id)")
        dbItem.title = newItem.title
        return dbItem.save(on: db)
    }
    
    private func save<T: Model>(_ item: T) {
        do {
            try item.save(on: db).wait()
        } catch {
            print(error)
        }
    }
}
