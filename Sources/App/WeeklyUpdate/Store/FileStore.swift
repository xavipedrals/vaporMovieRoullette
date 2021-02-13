//
//  File.swift
//  
//
//  Created by Xavier Pedrals Camprubí on 28/10/2020.
//

import Foundation

//protocol FileStore {
//    var fileManager: CustomFileManager { get set }
//    func fetchAllFiles<T: Codable>(withNameFilter: String?, in directory: FileDirectory) -> [T]
//    func getNumberForBatchFile(in directory: FileDirectory, namePart: String) -> Int
//}
//
//extension FileStore {
//    //number should be before .json and preceeded by a '-'
//    func getNumberForBatchFile(in directory: FileDirectory, namePart: String) -> Int {
//        let fileNames = fileManager.getFileNames(in: directory)
//        let filteredNames = fileNames.compactMap ({
//            return $0.contains(namePart)
//                ? $0
//                : nil
//        })
//        let numbers: [Int] = filteredNames.compactMap({
//            let parts = $0.split(separator: "-")
//            guard let aux = parts.last else { return nil }
//            let subparts = aux.split(separator: ".")
//            guard let number = subparts.first, let num = Int(number) else { return nil }
//            return num
//        })
//        guard let max = numbers.max() else { return filteredNames.count }
//        return max >= filteredNames.count ? max + 1 : filteredNames.count
//    }
//    
//    func fetchAllFiles<T: Codable>(withNameFilter: String?, in directory: FileDirectory) -> [T] {
//        let fileNames = fileManager.getFileNames(in: directory)
//        var filteredNames = fileNames
//        if let nameFilter = withNameFilter {
//            filteredNames = fileNames.compactMap {
//                return $0.contains(nameFilter)
//                    ? $0
//                    : nil
//            }
//        }
//        var items = [T]()
//        for name in filteredNames {
//            let data = fileManager.readFile(from: directory, name: name)
//            switch Parser<[T]>().parse(data: data) {
//            case .success(let result):
//                items.append(contentsOf: result)
//            case .failure(let error):
//                print(error)
//            }
//        }
//        return items
//    }
//}
