//
//  FileManager+Extension.swift
//  Passio-Nutrition-AI-iOS-UI-Module
//
//  Created by Nikunj Prajapati on 21/05/24.
//

import Foundation

extension FileManager {

    func getRecords<T: Codable>(for url: URL) -> [T] {
        var records = [T]()
        do {
            let directoryContents = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil)

            for fileURL in directoryContents {
                if let data = try? Data(contentsOf: fileURL) {
                    let decoder = JSONDecoder()
                    do {
                        let record = try decoder.decode(T.self, from: data)
                        records.append(record)
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
            }
            return records
        } catch {
            return records
        }
    }

    func updateRecordLocally(url: URL, record: Encodable) -> Bool {
        do {
            let encodedData = try? JSONEncoder().encode(record)
            if fileExists(atPath: url.path) {
                try removeItem(atPath: url.path)
            }
            do {
                try encodedData?.write(to: url)
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }

    @discardableResult
    func deleteRecordLocally(url: URL) -> Bool {
        if fileExists(atPath: url.path) {
            do {
                try removeItem(atPath: url.path)
                return true
            } catch {
                print("No record was found")
                return false
            }
        }
        return false
    }

    func clearTempDirectory() {
        do {
            let tempFiles = try contentsOfDirectory(at: temporaryDirectory,
                                                    includingPropertiesForKeys: nil,
                                                    options: [])
            for file in tempFiles {
                try removeItem(at: file)
            }
            // print("Temp directory cleared.")
        } catch {
            // print("Could not clear temp directory: \(error)")
        }
    }
}
