//
//  GlobalMessageServicePushNotification+CoreData.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation
import CoreData
import UIKit

/**
 Saves `self` to CoreData DB
 */
internal extension GlobalMessageServicePushNotification {
  
  /**
   Saves `self` to CoreData DB
   - Returns: `true` if successfully saved, `false` otherwise
   */
  func save() -> GMSInboxMessage? {
    
    guard UIApplication.sharedApplication().applicationState != .Inactive
      else { return .None }
    
    let moc = GlobalMessageServiceCoreDataHelper.managedObjectContext
    
    guard let entity =  NSEntityDescription.entityForName("GMSInboxMessage",
      inManagedObjectContext: moc),
      let coreDataPushNotification = NSManagedObject(entity: entity,
        insertIntoManagedObjectContext: moc) as? GMSInboxMessage
      else {
        return .None
    }
    
    coreDataPushNotification.messageID       = NSDecimalNumber(unsignedLongLong: gmsMessageID)
    coreDataPushNotification.message         = body
    coreDataPushNotification.setAlphaNameString(alphaName)
    coreDataPushNotification.deliveredDate   = NSDate().timeIntervalSinceReferenceDate
    coreDataPushNotification.type            = GlobalMessageServiceMessageType.PushNotification.rawValue
    
    coreDataPushNotification.setFethcedDate()
    
    let saveResult = GlobalMessageServiceCoreDataHelper.managedObjectContext.saveSafeRecursively()
    switch saveResult {
    case .Success:
      return coreDataPushNotification
    default:
      return .None
    }
    
    
    
  }
  
}
