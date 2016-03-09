//
//  GMSInboxAlphaName+Extension.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/25/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import CoreData

extension GMSInboxAlphaName: NSManagedObjectSearchable {
  
  // swiftlint:disable line_length
  /**
   Search and creates (if needed) `GMSInboxFetchedDate` object for passed date
   
   - parameter alphaName: `String` with Alpha name
   - parameter managedObjectContext: `NSManagedObjectContext` in what to search. (optional. Default value:
   `GlobalMessageServiceCoreDataHelper.managedObjectContext`)
   - returns: `self` if found, or successfully created, `nil` otherwise
   */
  internal static func getInboxAlphaName(
    alphaName name: String?,
    inManagedObjectContext managedObjectContext: NSManagedObjectContext? = GlobalMessageServiceCoreDataHelper.managedObjectContext)
    -> GMSInboxAlphaName? // swiftlint:disable:this opnening_brace
  {
    // swiftlint:enable line_length
    
    let aplhaNameString = name ?? unknownAlphaNameString
    
    let predicate = NSPredicate(format: "title == %@", aplhaNameString)
    guard let aplhaName = GMSInboxAlphaName.findObject(
      withPredicate: predicate,
      inManagedObjectContext: managedObjectContext) as? GMSInboxAlphaName
      else // swiftlint:disable:this opnening_brace
    {
        return .None
    }
    
    aplhaName.title = aplhaNameString
    
    return aplhaName
  }
  
  /**
   Unlocalized default string for unknown alpha-name in remote push-notification
   */
  internal static var unknownAlphaNameString: String {
    return "_UNKNOWN_ALPHA_NAME_"
  }
  
}
