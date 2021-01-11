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
    
    private init() {}
    
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
    
    func getItemsToEnrich() -> [AudioVisual] {
        let audiovisualsToEnrich = try? AudioVisual.query(on: db)
            .filter(\.$tmdbId == nil)
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
    
    private func save<T: Model>(_ item: T) {
        do {
            try item.save(on: db).wait()
        } catch {
            print(error)
        }
    }
}
