//
//  ExtensionNSManagedObject.swift

import Foundation
import CoreData

extension NSManagedObject {
    
    static var entityName: String {
        return NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last ?? ""
    }
    static var entityDescription: NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: mainManagedObjectContext)
    }
    static var mainManagedObjectContext: NSManagedObjectContext {
        return CoreDataManager.shared.mainManagedObjectContext
    }
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return CoreDataManager.shared.persistentStoreCoordinator
    }
    static var privateMangedObjectContext: NSManagedObjectContext {
        return CoreDataManager.shared.privateMangedObjectContext
    }
    static var mediatorMangedObjectContext: NSManagedObjectContext {
        return CoreDataManager.shared.mediatorMangedObjectContext
    }
    static var childMangedObjectContext: NSManagedObjectContext {
        return CoreDataManager.shared.childMangedObjectContext
    }
    static var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        return fetchRequest
    }
    fileprivate static var batchUpdateRequest: NSBatchUpdateRequest {
        if let entityDescription = entityDescription {
            return NSBatchUpdateRequest(entity: entityDescription)
        } else {
            return NSBatchUpdateRequest(entityName: entityName)
        }
    }
    fileprivate static var batchDeleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }
}

extension NSManagedObject {
    
    fileprivate static func dictToPredicate(dict: [String: Any]) -> NSPredicate {
        
        var arrPredicates = [NSPredicate]()
        for (key , value) in dict {
            arrPredicates.append(NSPredicate(format: "%K == %@", key , (value as? NSObject) ?? ""))
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: arrPredicates)
    }
}

extension NSManagedObject {
    
    static func findOrCreate(dict: [String: Any]) -> NSManagedObject {
        
        guard let managedObject = findoutManagedObject(dict: dict, context: mainManagedObjectContext) else {
            return createManagedObject(dict: dict, context: mainManagedObjectContext)
        }
        return managedObject
    }
    
    static func findOrCreateWithMultipleMOC(dict: [String: Any]) -> NSManagedObject {
        
        guard let managedObject = findoutManagedObject(dict: dict, context: childMangedObjectContext) else {
            return createManagedObject(dict: dict, context: childMangedObjectContext)
        }
        return managedObject
    }
    
    fileprivate static func findoutManagedObject(dict: [String: Any], context: NSManagedObjectContext) -> NSManagedObject? {
        
        let fRequest = fetchRequest
        fRequest.predicate = dictToPredicate(dict: dict)
        
        do { return try context.fetch(fRequest).last as? NSManagedObject }
            
        catch {
            passioLog(message: "Error while finding the NSManagedObject with dict :-(dict) AND error is :- (error.localizedDescription)")
        }
        return nil
    }
    
    fileprivate static func createManagedObject(dict: [String: Any], context: NSManagedObjectContext) -> NSManagedObject {
        
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
        if let attributes = entityDescription?.attributesByName {
            for (key , _) in attributes {
                managedObject.setValue(dict[key], forKey: key)
            }
        }
        return managedObject
    }
}

extension NSManagedObject {
    
    static func fetch(predicate: NSPredicate) -> [NSManagedObject]? {
        return fetch(predicate: predicate, sortDescriptor: nil)
    }
    
    static func fetch(sortDescriptor: [NSSortDescriptor]) -> [NSManagedObject]? {
        return fetch(predicate: nil, sortDescriptor: sortDescriptor)
    }
    
    static func fetch(predicate: NSPredicate?, sortDescriptor: [NSSortDescriptor]?) -> [NSManagedObject]? {
        
        let fRequest = fetchRequest
        fRequest.predicate = predicate
        fRequest.sortDescriptors = sortDescriptor
        
        do { return try mainManagedObjectContext.fetch(fRequest) as? [NSManagedObject] }
            
        catch {
            passioLog(message: "Error while fetching the NSManagedObjects with dict :- \(predicate ?? NSPredicate()) , sortDescriptor :- \(sortDescriptor ?? [NSSortDescriptor()]) AND error is :- \(error.localizedDescription)")
        }
        return nil
    }
    
    static var allObjects: [Any]? {
        
        do { return try mainManagedObjectContext.fetch(fetchRequest)}
            
        catch {
            passioLog(message: "Error while fetching all NSManagedObjects from entity\(entityName) :- \(error.localizedDescription)")
        }
        return nil
    }
}

extension NSManagedObject {
    
    static func update(dict: [String: Any], predicate: NSPredicate?) {
        
        let buRequest = batchUpdateRequest
        buRequest.propertiesToUpdate = dict
        buRequest.predicate = predicate
        buRequest.resultType = .updatedObjectIDsResultType
        
        let managedObjectContext = mainManagedObjectContext
        
        do {
            if let buResult = try managedObjectContext.execute(buRequest) as? NSBatchUpdateResult {
                if let managedObjectIDs = buResult.result as? [NSManagedObjectID] {
                    for id in managedObjectIDs {
                        let managedObject = managedObjectContext.object(with: id)
                        managedObjectContext.refresh(managedObject, mergeChanges: false)
                    }
                }
            }
            
        } catch {
            passioLog(message: "Error while updating the NSManagedObjects with dict :- \(dict) , predicate :- \(predicate ?? NSPredicate()) AND error is :- \(error.localizedDescription)")
        }
    }
}

extension NSManagedObject {
    
    func delete() {
        let managedObjectContext = NSManagedObject.mainManagedObjectContext
        managedObjectContext.delete(self)
    }
}

extension NSManagedObject {
    
    static func delete(predicate: NSPredicate) {
        
        let fRequest = fetchRequest
        fRequest.predicate = predicate
        
        let bdRequest = NSBatchDeleteRequest(fetchRequest: fRequest)
        bdRequest.resultType = .resultTypeCount
        
        let managedObjectContext = mainManagedObjectContext
        
        do {
            try managedObjectContext.execute(bdRequest)
            managedObjectContext.reset()
        }
        catch {
            passioLog(message: "Error while delete all NSManagedObjects with predicate :- \(predicate) AND error is :- \(error.localizedDescription)")
        }
    }
    
    static func deleteAll() {
        
        let bdRequest = batchDeleteRequest
        bdRequest.resultType = .resultTypeCount
        
        let managedObjectContext = mainManagedObjectContext
        
        do {
            try managedObjectContext.execute(bdRequest)
            managedObjectContext.reset()
        }
        catch {
            passioLog(message: "Error while delete all NSManagedObjects AND error is :- \(error.localizedDescription)")
        }
    }
}

