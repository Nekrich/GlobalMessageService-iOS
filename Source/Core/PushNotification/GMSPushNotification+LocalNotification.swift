//
//  GlobalMessageServicePushNotification+LocalNotification.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import UIKit

/**
 Presents `GlobalMessageServicePushNotification` as `UILocalNotification`
 */
public extension GlobalMessageServicePushNotification {
  
  /**
   Returns `UILocalNotification` initialized with `self`
   - Returns: New `UILocalNotification` object
   */
  public func localNotification() -> UILocalNotification {
    
    let localNotification = UILocalNotification()
    
    localNotification.timeZone = NSTimeZone.defaultTimeZone()
    localNotification.alertBody = body
    
    if #available(iOS 8.2, *) {
      localNotification.alertTitle = title
    }
    
    localNotification.alertAction = actionLocalizationKey
    localNotification.hasAction = actionLocalizationKey != .None
    
    localNotification.soundName = sound
    localNotification.applicationIconBadgeNumber = bage ?? 0
    
    localNotification.alertLaunchImage = launchImage
    
    localNotification.category = category
    
    localNotification.fireDate = NSDate()
    
    return localNotification
    
  }
  
}
