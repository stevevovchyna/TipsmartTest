//
//  DataManager.swift
//  TipstartTest
//
//  Created by Steve Vovchyna on 31.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import CoreData

public class ItemManager : NSObject {
    
    var context : NSManagedObjectContext
    
    public override init() {
        let bundle = Bundle(identifier: "com.stevevovchyna.TipstartTest")
        
        guard let url = bundle?.url(forResource: "TipstartTest", withExtension: "momd") else { fatalError("Error loading model from the bundle") }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else { fatalError("Couldn't initialize managed object model from set url") }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        
        if let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            let storageURL = documentURL.appendingPathComponent("TipstartTest.sqlite")
            
            do {
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: nil)
            } catch {
                fatalError("Error adding persistent store \(error)")
            }
        } else {
            fatalError("Error locating storage")
        }
    }
    
    public func newItem() -> Cache {
        return NSEntityDescription.insertNewObject(forEntityName: "Cache", into: context) as! Cache
    }
    
    func fetchData(predicate : NSPredicate) -> [Cache] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cache")
        
        fetchRequest.predicate = predicate
        
        do {
            let fetchResult = try context.fetch(fetchRequest) as! [Cache]
            return fetchResult
        } catch {
            fatalError("Error fetching data!")
        }
    }
    
    public func removeAllItems() {
        let allItems = self.getAllItems()
        for item in allItems {
            context.delete(item)
        }
    }
    
    public func getAllItems() -> [Cache] {
        return fetchData(predicate: NSPredicate(value: true))
    }
 
    public func removeItem(item : Cache) {
        context.delete(item)
    }
    
    public func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }
        }
    }
    
    
}
