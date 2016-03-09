//
//  GlobalMessageServiceHelper+RemoteNotifications.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation

/**
 The delegate of a `GlobalMessageService` object must adopt the 
 `GlobalMessageServiceRemoteNotificationReciever` protocol.
 Methods of the protocol allow the reciever to manage receiving of remote push-notifications
*/
public protocol GlobalMessageServiceRemoteNotificationReciever: class {
  // swiftlint:disable line_length
  /**
   - Parameter userInfo: A dictionary that contains information related to the remote notification, 
   potentially including a badge number for the app icon, an alert sound, an alert message 
   to display to the user, a notification identifier, and custom data. The provider originates it 
   as a JSON-defined dictionary that iOS converts to an NSDictionary object; the dictionary may contain 
   only property-list objects plus NSNull. For more information about the contents of the remote notification 
   dictionary, see [Local and Remote Notification Programming Guide](xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/Introduction.html#//apple_ref/doc/uid/TP40008194).
  - Parameter pushNotification: `GlobalMessageServicePushNotification` `struct` if notification rcieved from 
  Global Message Services, `nil` otherwise
   */
  func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject],
    pushNotification:GlobalMessageServicePushNotification?) // swiftlint:disable:this colon
  // swiftlint:enable line_length
}

private extension GlobalMessageServiceHelper {
  
  /**
   Handles receiving of push-notification
   - Parameter userInfo: Recieved pushnotification payload dictionary
   - Returns: `GlobalMessageServicePushNotification` if notifications allowed, user authorized, 
   notification in correct format and saved into Inbox. Otherwise returns `nil`
   */
  func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject])
    -> GlobalMessageServicePushNotification? // swiftlint:disable:this opening_brace
  {
    
    gmsLog.verbose("userInfo: \(userInfo.description)")
    
    var newUserInfo: [NSObject : AnyObject] = userInfo ?? [NSObject : AnyObject]()
    
    if let dataDictionary = newUserInfo["data"] as? [String : AnyObject] {
      for (key, value) in dataDictionary {
        newUserInfo[key] = value
      }
      newUserInfo["data"] = nil
    }
    
    let notificationsAllowed = (UIApplication.sharedApplication().currentUserNotificationSettings()?.types
        ?? UIUserNotificationType.None) != UIUserNotificationType.None
    
    let pushNotification = GlobalMessageServicePushNotification(
      withUserInfo: newUserInfo,
      notificationsAllowed: notificationsAllowed)
    
    internalRemoteNotificationsDelegate?.didReceiveRemoteNotification(
      userInfo,
      pushNotification: pushNotification)
    
    if let pushNotification = pushNotification//,
      //gmsMessageID = pushNotification.gmsMessageID
      where pushNotification.gmsMessageID != 0
        && notificationsAllowed
        && settings.gmsToken > 0 // swiftlint:disable:this opening_brace
    {
      if !settings.authorized {
        GlobalMessageService.allowRecievePush(false)
        return .None
      }
      
      let requestParameters: [String : AnyObject] = [
        "uniqAppDeviceId": NSNumber(unsignedLongLong: settings.gmsToken),
        "msg_gms_uniq_id": NSNumber(unsignedLongLong: pushNotification.gmsMessageID),
        "status": 1
      ]
      
      GMSProvider.sharedInstance.POST(
        .OTTPlatform,
        "deliveryReport",
        parameters: requestParameters) { result in
          
      }
      
      if let _ = pushNotification.save() {
        UIApplication.sharedApplication().presentLocalNotificationNow(pushNotification.localNotification())
      }
      
      //GlobalMessageService.googleCloudMessagingHelper?.didReceiveRemoteNotification(userInfo)
      
      //return pushNotification
      
    }
    
    
    
    if let _ = pushNotification?.gcmMessageID {
      
      GlobalMessageService.googleCloudMessagingHelper?.didReceiveRemoteNotification(userInfo)
      gmsLog.verbose("recieved message that was sended by GSM")
      return pushNotification
      
    } else {
      
      gmsLog.verbose("recieved message from someone, that was not sended by GSM or GMS.")
      return .None
      
    }
    
  }
  
  /// Handles registration for push-notification receiving
  /// - Parameter deviceToken: registered remote Apple Push-notifications device doken
  func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
    
    gmsLog.verbose("didRegisterForRemoteNotificationsWithDeviceToken")
    
    let newAPNsTokenString = deviceToken.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    let oldAPNsTokenString = settings.apnsToken ?? ""
    
    if oldAPNsTokenString != newAPNsTokenString {
      
      gmsLog.verbose("New APNs Token: \"\(newAPNsTokenString)\" (was: \"\(oldAPNsTokenString)\")")
      
      settings.apnsToken = newAPNsTokenString
      
    } else {
      gmsLog.verbose("Same APNs token: \(newAPNsTokenString)")
    }
    
  }
  
}

public extension GlobalMessageService {
  
  /**
   Handles registration for push-notification receiving
   
   Call this func in 
   
   `func application(application: UIApplication, 
   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)`
   
   in your `AppDelegate` module
   
   - Parameter deviceToken: registered remote Apple Push-notifications device doken
   */
  public static func didRegisterForRemoteNotificationsWithDeviceToken(
    deviceToken: NSData) // swiftlint:disable:this opening_brace
  {
    
    helper.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    
    googleCloudMessagingHelper?.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    
  }
  
  /**
   Handles receiving of push-notification
   
   Call this func in
   
   `func application(application: UIApplication, 
   didReceiveRemoteNotification userInfo: [NSObject : AnyObject])`
   
   in your `AppDelegate` module
   
   - Parameter userInfo: Recieved pushnotification payload dictionary
   
   - Returns: `GlobalMessageServicePushNotification` if notifications allowed, user authorized, 
   notification in correct format and saved into Inbox. Otherwise returns `nil`
   */
  public static func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject])
    -> GlobalMessageServicePushNotification? // swiftlint:disable:this opening_brace
  {
    
    let pushNotification = helper.didReceiveRemoteNotification(userInfo)
    
    googleCloudMessagingHelper?.didReceiveRemoteNotification(userInfo)

    return pushNotification
    
  }
  
}
