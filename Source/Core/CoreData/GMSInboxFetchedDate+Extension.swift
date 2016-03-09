//
//  GMSInboxFetchedDate+Extension.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import Foundation
import CoreData

extension GMSInboxFetchedDate: NSManagedObjectSearchable {
  // swiftlint:disable line_length
  /**
   Search and creates (if needed) `GMSInboxFetchedDate` object for passed date
   
   - parameter date: `NSTimeInterval` for date from 00:00:00 UTC on 1 January 2001
   - parameter managedObjectContext: `NSManagedObjectContext` in what to search. (optional. Default value: 
   `GlobalMessageServiceCoreDataHelper.managedObjectContext`)
   - parameter createNewIfNotFound: `true`, `false` otherwise
   - returns: `self` if found, or \``createNewIfNotFound: true`\` passed, `nil` otherwise
   */
  internal static func getInboxFetchedDate(
    forDate date: NSTimeInterval,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext? = GlobalMessageServiceCoreDataHelper.managedObjectContext,
    createNewIfNotFound createNew: Bool = false)
    -> GMSInboxFetchedDate? // swiftlint:disable:this opening_brace
  {
    // swiftlint:enable line_length
    guard let registeredUserPhone = GlobalMessageService.registeredUserPhone else {
      return .None
    }
    
    let startOfDay = NSDate(timeIntervalSinceReferenceDate: date).startOfDay()
    
    let predicate = NSPredicate(format: "fetchedDate == %@ && to == \(registeredUserPhone)", startOfDay)
    guard let fetchedDate = GMSInboxFetchedDate.findObject(
      withPredicate: predicate,
      inManagedObjectContext: managedObjectContext,
      createNewIfNotFound: createNew) as? GMSInboxFetchedDate
      else { // swiftlint:disable:this statement_position
        return .None
    }
    
    if fetchedDate.fetchedDate != startOfDay.timeIntervalSinceReferenceDate {
      fetchedDate.fetchedDate = startOfDay.timeIntervalSinceReferenceDate
    }
    
    let newLastMessageDate: NSTimeInterval
    if fetchedDate.fetchedDate == NSDate().startOfDay().timeIntervalSinceReferenceDate {
      newLastMessageDate = max(startOfDay.timeIntervalSinceReferenceDate, fetchedDate.lastMessageDate)
    } else if fetchedDate.fetchedDate > NSDate().endOfDay().timeIntervalSinceReferenceDate {
      newLastMessageDate = startOfDay.timeIntervalSinceReferenceDate
    } else {
      newLastMessageDate = startOfDay.endOfDay().timeIntervalSinceReferenceDate
    }
    
    if fetchedDate.lastMessageDate != newLastMessageDate {
      fetchedDate.lastMessageDate = newLastMessageDate
    }
    if fetchedDate.to != registeredUserPhone {
      fetchedDate.to = registeredUserPhone
    }
    if fetchedDate.fetchedDate != startOfDay.timeIntervalSinceReferenceDate {
      fetchedDate.fetchedDate = startOfDay.timeIntervalSinceReferenceDate
    }
    return fetchedDate
    
  }
  
  /**
   Sets `lastMessageDate` if `self` contains todays date
   */
  private func setLastMessageDate() {
    if fetchedDate == NSDate().startOfDay().timeIntervalSinceReferenceDate {
      let newLastMessageDate: NSTimeInterval
      
      var maxDeliveredDate: NSTimeInterval? = .None
      let messagesSet = messages as? Set<GMSInboxMessage>
      messagesSet?.forEach() { message in
        if message.type != GlobalMessageServiceMessageType.PushNotification.rawValue {
          maxDeliveredDate = max(maxDeliveredDate ?? 0, message.deliveredDate)
        }
      }
      
      if let _lastMessageDate = maxDeliveredDate {
        newLastMessageDate = _lastMessageDate
      } else {
        newLastMessageDate = lastMessageDate
      }
      if lastMessageDate != newLastMessageDate {
        lastMessageDate = newLastMessageDate
      }
    }
  }
  
  internal override func willSave() {
    
    setLastMessageDate()
    
    super.willSave()
  }
  
}
