//
//  CoreDataManager.swift

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    private init() {}
    
    fileprivate static let fileName = "PassioFood"
    fileprivate static let fileExtension = "xcdatamodeld"
    
    private static var coreDataManager: CoreDataManager = {
        let coreDataManager = CoreDataManager()
        return coreDataManager
    }()
    
    static var shared: CoreDataManager = {
        copyFileIfNotExists()
        return coreDataManager
    }()
    
    fileprivate static func copyFileIfNotExists() {
        
        let fileManager = FileManager.default
        
        // Get the documents directory URL
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find the documents directory.")
            return
        }
        
        let destinationURL = documentsDirectory.appendingPathComponent("\(fileName).\(fileExtension)")
        
        // Check if the file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("File already exists at path: \(destinationURL.path)")
            return
        }
        
        // Get the source URL for the file in the package resources
        
        guard let sourceURL = Bundle.module.url(forResource: fileName, withExtension: "momd") else {
            print("File not found in package resources.")
            return
        }
        
        do {
            // Copy the file
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("File copied to: \(destinationURL.path)")
        } catch {
            print("Error copying file: \(error)")
        }
    }
    
    fileprivate static var persistentContainer: NSPersistentContainer = {
        var container = NSPersistentContainer(name: fileName)
        
        if let docuemntDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let coreDataFileURL = docuemntDirectory.appendingPathComponent("\(fileName).\(fileExtension)")
            if let managedURL = NSManagedObjectModel(contentsOf: coreDataFileURL) {
                container = NSPersistentContainer(name: fileName, managedObjectModel: managedURL)
            }
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy private(set) var mainManagedObjectContext: NSManagedObjectContext = {
        return CoreDataManager.persistentContainer.viewContext
    }()
    
    lazy private(set) var backgroundManagedObjectContext: NSManagedObjectContext = {
        return CoreDataManager.persistentContainer.newBackgroundContext()
    }()
    
    lazy private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        return CoreDataManager.persistentContainer.persistentStoreCoordinator
    }()
    
    lazy private(set) var privateMangedObjectContext: NSManagedObjectContext = {
        let privateMangedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMangedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return privateMangedObjectContext
    }()
    
    lazy private(set) var mediatorMangedObjectContext: NSManagedObjectContext = {
        let mediatorMangedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mediatorMangedObjectContext.parent = privateMangedObjectContext
        return mediatorMangedObjectContext
    }()
    
    lazy private(set) var childMangedObjectContext: NSManagedObjectContext = {
        let childMangedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childMangedObjectContext.parent = mediatorMangedObjectContext
        return childMangedObjectContext
    }()
}

extension CoreDataManager {
    
    func save() {
        mainManagedObjectContext.saveChanges()
    }
    
    func saveChangesOnMultipleMOC() {
        NSManagedObjectContext.saveChangesOnMultipleMOC(childManagedObjectContext: childMangedObjectContext, mediatorMangedObjectContext: mediatorMangedObjectContext, privateManagedObjectContext: privateMangedObjectContext)
    }
}
