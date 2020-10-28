//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation
import Files

enum FileDirectory {
    case root
    case input
    case netflixBaseMovies
    case netflixTMDBEnrichedMovies
    case netflixFinalMovies
    case netflixFinalCompressedMovies
    case topListsOutput
    case weeklyUpdates
    case realWeekUpdate(date: Date)
    case prodReady(date: Date)
    case prodAllMovies
}

class CustomFileManager {
    
    static let instance = CustomFileManager()
    
    var movieScriptsFolder: Folder
    var inputFolder: Folder
    var topListsOutputFolder: Folder
    var netflixFolder: Folder
    var netflixBaseFolder: Folder
    var netflixFinalFolder: Folder
    var netflixCompressedFinalFolder: Folder
    var netflixTMDBEnrichedFolder: Folder
    var weeklyUpdatesFolder: Folder
    
    private init() {
        movieScriptsFolder = try! Folder.home.createSubfolderIfNeeded(withName: "movieScriptsFolder")
        inputFolder = try! movieScriptsFolder.createSubfolderIfNeeded(withName: "topListsInput")
        netflixFolder = try! movieScriptsFolder.createSubfolderIfNeeded(withName: "netflix")
        netflixBaseFolder = try! netflixFolder.createSubfolderIfNeeded(withName: "baseMovies")
        netflixTMDBEnrichedFolder = try! netflixFolder.createSubfolderIfNeeded(withName: "tmdbEnrichedMovies")
        netflixFinalFolder = try! netflixFolder.createSubfolderIfNeeded(withName: "finalMovies")
        netflixCompressedFinalFolder = try! netflixFolder.createSubfolderIfNeeded(withName: "finalCompressed")
        topListsOutputFolder = try! movieScriptsFolder.createSubfolderIfNeeded(withName: "topListsOutput")
        weeklyUpdatesFolder = try! movieScriptsFolder.createSubfolderIfNeeded(withName: "weeklyUpdates")
    }
    
    func formatJSONDataToString(_ data: Data) -> String {
        let string = String(data: data, encoding: .utf8)!
        return string.replacingOccurrences(of: "\\", with: "")
    }
    
    func write<T: Codable>(array: [T], directory: FileDirectory, filename: String) {
        let folder = getFolder(from: directory)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(array)
            let wellFormattedString = formatJSONDataToString(data)
            writeToFile(in: folder, name: filename, string: wellFormattedString)
        } catch {
            print(error)
        }
    }
    
    func write<T: Codable>(obj: T, directory: FileDirectory, filename: String) {
        let folder = getFolder(from: directory)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(obj)
            let wellFormattedString = formatJSONDataToString(data)
            writeToFile(in: folder, name: filename, string: wellFormattedString)
        } catch {
            print(error)
        }
    }
    
    func getInputListFileNames() -> [String] {
        return getFileNames(in: inputFolder)
    }
    
    func getFileNames(in directory: FileDirectory) -> [String] {
        return getFileNames(in: getFolder(from: directory))
    }
    
    func readTopList(with name: String) -> Data {
        return readFile(from: inputFolder, name: name)
    }
    
    func readFile(from directory: FileDirectory, name: String) -> Data {
        return readFile(from: getFolder(from: directory), name: name)
    }
    
    func deleteAllFiles(in directory: FileDirectory) {
        let folder = getFolder(from: directory)
        for file in folder.files {
            try? file.delete()
        }
    }
    
    //MARK: - Private
    
    private func readFile(from folder: Folder, name: String) -> Data {
        let file = try! folder.file(named: name)
        let data = try! file.read()
        return data
    }
    
    private func writeToFile(in folder: Folder, name: String, string: String) {
        do {
            let file = try folder.createFileIfNeeded(withName: name)
            try file.write(string: string, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    private func getFileNames(in folder: Folder) -> [String] {
        return folder.files.compactMap({ $0.name })
    }
    
    private func getFolder(from directory: FileDirectory) -> Folder {
        switch directory {
        case .root:
            return movieScriptsFolder
        case .input:
            return inputFolder
        case .netflixBaseMovies:
            return netflixBaseFolder
        case .topListsOutput:
            return topListsOutputFolder
        case .netflixTMDBEnrichedMovies:
            return netflixTMDBEnrichedFolder
        case .netflixFinalMovies:
            return netflixFinalFolder
        case .netflixFinalCompressedMovies:
            return netflixCompressedFinalFolder
        case .weeklyUpdates:
            return weeklyUpdatesFolder
        case .realWeekUpdate(let date):
            let calendar = Calendar(identifier: .gregorian)
            let comp = calendar.dateComponents([.year, .weekOfYear], from: date)
            guard let year = comp.year else {
                fatalError("Could not get week components")
            }
            return try! movieScriptsFolder.createSubfolderIfNeeded(withName: "\(year)")
        case .prodReady(let date):
            let yearFolder = getFolder(from: .realWeekUpdate(date: date))
            let calendar = Calendar(identifier: .gregorian)
            let comp = calendar.dateComponents([.year, .weekOfYear], from: date)
            guard let weekOfYear = comp.weekOfYear else {
                fatalError("Could not get week components")
            }
            return try! yearFolder.createSubfolderIfNeeded(withName: "\(weekOfYear)")
        case .prodAllMovies:
            let yearFolder = getFolder(from: .realWeekUpdate(date: Date()))
            return try! yearFolder.createSubfolderIfNeeded(withName: "all")
        }
    }
}
