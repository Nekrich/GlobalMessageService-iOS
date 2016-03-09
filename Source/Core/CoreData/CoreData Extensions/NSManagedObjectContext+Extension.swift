//
//  NSManagedObjectContext+Extension.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import CoreData

/**
 Provides deletion of entities methods
 */
internal extension NSManagedObjectContext {
  
  /**
   Erases all stored data
   - Returns: `SaveResult`
   */
  func deleteObjectctsOfAllEntities() -> SaveResult {
    
    return deleteObjectctsOfEntities(persistentStoreCoordinator?.managedObjectModel.entities)
    
  }
  
  /**
  Erases all stored data in passed `NSEntityDescription`s
   - Parameter entities: `NSEntityDescription` array, that must to be erazed
  - Returns: `SaveResult`
  */
  func deleteObjectctsOfEntities(entities: [NSEntityDescription]?) -> SaveResult {
    guard let entities = entities else { return .Success }
    var error: NSError? = .None
    entities.forEach { entity in
      if let entityName = entity.name where !entity.abstract {
        
        let result = deleteObjectctsOfEntity(entityName, save: false)
        switch result {
        case .Failure(let err):
          error = err
          break
        default:
          break
        }
      }
    }
    if let error = error {
      return .Failure(error)
    } else {
      return saveSafeRecursively()
    }
  }
  
  /**
   Erases all stored data in entity with name
   - Parameter entityName: The entity name to be erased
   - Parameter save: `Bool` flag that tells to save context after deleting all objects or not. 
   Default value - `true`
   - Returns: `SaveResult`
   */
  func deleteObjectctsOfEntity(entityName: String, save: Bool = true) -> SaveResult {
    
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.includesPropertyValues = false
    
    let results: [NSManagedObject]?
    do {
      results = try executeFetchRequest(fetchRequest) as? [NSManagedObject]
    } catch {
      gmsLog.error("executeFetchRequest error: \(error)")
      return .Failure(error as NSError)
    }
    
    guard let fetchedObjects = results else {
      return .Failure(NSError(
        domain: "",
        code: 1,
        userInfo: ["description": "Could not cast Fetch Request result to [NSManagedObject]"]))
    }
    
    for object in fetchedObjects {
      deleteObject(object)
    }
    
    if save {
      return saveSafeRecursively()
    }
    
    return .Success
    
  }
  
}

/**
 Provides `saveRecursively` and `saveSafeRecursively() -> SaveResult` methods
 */
internal extension NSManagedObjectContext {
  
  /**
   Saves `self` recursively and waits for response (uses all `parentContext`s)
   - Throws: `NSError`
   */
  func saveRecursively() throws {
    
    guard hasChanges else { return }
    
    var saveError: ErrorType? = .None
    
    performBlockAndWait() {
      do {
        try self.save()
      } catch {
        print("NSManagedObjectContext couldn't be saved \(error) ")
        saveError = error
      }
    }
    if let saveError = saveError {
      throw saveError
    }
    
    try parentContext?.saveRecursively()
    
  }
  
  /**
   Enum representing result of saving context
   
   - Success: Saved successfully
   - Failure: An error occurred. Contains `NSError` that represents error
   */
  enum SaveResult {
    
    /// Saved successfully
    case Success
    
    /// An error occurred. Contains `NSError` that represents error
    case Failure(NSError)
  }
  
  /**
   Saves `self` recursively and waits for response (uses all `parentContext`s). No `throw`s
   - Returns: `SaveResult`
   */
  func saveSafeRecursively() -> SaveResult {
    
    guard hasChanges else { return .Success }
    
    var result = SaveResult.Success
    performBlockAndWait() {
      do {
        try self.save()
      } catch {
        print("NSManagedObjectContext couldn't be saved \(error) context: \(self)")
        result = .Failure(error as NSError)
      }
    }
    
    switch result {
    case .Failure(_):
      return result
    default:
      break
    }
    
    return parentContext?.saveSafeRecursively() ?? .Success
    
  }
  
}
