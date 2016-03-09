//
//  GMSInboxMessage+Extension.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/26/16.
//
//

import Foundation
import CoreData

extension GMSInboxMessage: NSManagedObjectSearchable {
  /**
   Sets `fetchedDate` into object
   - parameter deliveredDateDay: `NSTimeInterval` for date from 00:00:00 UTC on 1 January 2001. 
   (optional. If not passed uses `self.deliveredDate`)
   */
  internal func setFethcedDate(deliveredDateDay: NSTimeInterval? = .None) {
    let newDeliveredDateDay: NSTimeInterval
    if let deliveredDateDay = deliveredDateDay {
      newDeliveredDateDay = deliveredDateDay
    } else {
      newDeliveredDateDay = NSDate(timeIntervalSinceReferenceDate: deliveredDate)
        .startOfDay()
        .timeIntervalSinceReferenceDate
    }
    if fetchedDate?.fetchedDate != newDeliveredDateDay {
      if let fetchedDate = GMSInboxFetchedDate.getInboxFetchedDate(
        forDate: newDeliveredDateDay,
        inManagedObjectContext: managedObjectContext,
        createNewIfNotFound: true) // swiftlint:disable:this opening_brace
      {
        self.fetchedDate = fetchedDate
      }
    }
  }
  
  internal override func willSave() {
    
    let newDeliveredDateDay = NSDate(timeIntervalSinceReferenceDate: deliveredDate)
      .startOfDay()
      .timeIntervalSinceReferenceDate
    
    setFethcedDate(newDeliveredDateDay)
    
    super.willSave()
    
  }
  
  /**
   Makes `GlobalMessageServiceMessage` struct for current object
   - returns: `GlobalMessageServiceMessage` if sucessfuly converted, otherwise returns `nil`
   */
  func gmsMessage() -> GlobalMessageServiceMessage? {
    return GlobalMessageServiceMessage(message: self)
  }
  
  /**
   Sets new `String` with `alphaName` to message
   - Parameter newAlphaName: New aplha-name to be setted
   */
  func setAlphaNameString(newAlphaName: String?) {
    let newAlphaNameString = newAlphaName ?? GMSInboxAlphaName.unknownAlphaNameString
    guard alphaName?.title != newAlphaNameString else { return }
    alphaName = GMSInboxAlphaName.getInboxAlphaName(
        alphaName: newAlphaNameString,
        inManagedObjectContext: self.managedObjectContext)
  }
  
  /**
   Returns `String` with alpha-name
   - Returns: `String` with alpha-name
   */
  func getAlphaNameString() -> String {
    return alphaName?.title ?? GMSInboxAlphaName.unknownAlphaNameString
  }
  
  
}
