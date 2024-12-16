//
//  ExtesionNSManagedObjectContext.swift

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    func saveChanges() {
        
        if self.hasChanges {
            do {
                try save()
            }
            catch {
                print( "Error while saving the Single Change into NSManagedObjectContext :- \(error.localizedDescription)")
            }
        }
    }
    
   static func saveChangesOnMultipleMOC(childManagedObjectContext: NSManagedObjectContext, mediatorMangedObjectContext: NSManagedObjectContext, privateManagedObjectContext: NSManagedObjectContext) {
        
        saveChangesOnChildContext(childManagedObjectContext: childManagedObjectContext, mediatorMangedObjectContext: mediatorMangedObjectContext, privateManagedObjectContext: privateManagedObjectContext)
    }
    
    private static func saveChangesOnChildContext(childManagedObjectContext: NSManagedObjectContext, mediatorMangedObjectContext: NSManagedObjectContext, privateManagedObjectContext: NSManagedObjectContext) {
        
        if childManagedObjectContext.hasChanges {
            do {
                try childManagedObjectContext.save()
                self.saveChangesOnMediatorContext(mediatorMangedObjectContext: mediatorMangedObjectContext, privateManagedObjectContext: privateManagedObjectContext)
            }
            catch {
                print( "Error while saving the Changes into ChildNSManagedObjectContext :- (error.localizedDescription)")
            }
        }
    }
    
    private static func saveChangesOnMediatorContext(mediatorMangedObjectContext: NSManagedObjectContext, privateManagedObjectContext: NSManagedObjectContext) {
        
        mediatorMangedObjectContext.perform {
            if mediatorMangedObjectContext.hasChanges {
                do {
                    try mediatorMangedObjectContext.save()
                    self.saveChangesOnPrivateContext(privateManagedObjectContext: privateManagedObjectContext)
                }
                catch {
                    print( "Error while saving the Changes into MediatorNSManagedObjectContext :- (error.localizedDescription)")
                }
            }
        }
    }
    
    private static func saveChangesOnPrivateContext(privateManagedObjectContext: NSManagedObjectContext) {
        
        privateManagedObjectContext.performAndWait {
            if privateManagedObjectContext.hasChanges {
                do {
                    try privateManagedObjectContext.save()
                }
                catch {
                    print( "Error while saving the Changes into PrivateNSManagedObjectContext :- (error.localizedDescription)")
                }
            }
        }
    }
}
