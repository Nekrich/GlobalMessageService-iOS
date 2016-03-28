//
//  GlobalMessageServiceObject.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/10/16.
//
//

import Foundation
import Alamofire
//import GoogleCloudMessaging

/**
 Global Message Service Helper.
  - Note: No internal and public initializers aviable
 */
internal class GlobalMessageServiceHelper {
  
  /// Application key. (private)
  private var applicationKey: String? = .None
  
  /// A pointer to currently running addSubscriber `Request`. (internal)
  internal var addSubscriberTask: Request? = .None
  
  /// A pointer to currently running updateSubscriberInfo `Request`. (internal)
  internal var updateSubscriberInfoTask: Request? = .None
  
  /// A pointer to currently running updateGCMToken `Request`. (internal)
  //internal var updateGCMTokenTask: Request? = .None
  
  /// A pointer to current settings `GMSSettings`. (internal)
  internal lazy var settings: GlobalMessageServiceSettings = {
    GlobalMessageServiceSettings.currentSettings
  }()
  
  /// Private initializer
  private init() {}
  
  // swiftlint:disable line_length
  /// Framework remote notifications delegate (`GlobalMessageServiceMessageFetcherJSQ`)
  internal weak var internalRemoteNotificationsDelegate: GlobalMessageServiceRemoteNotificationReciever? = .None
  // swiftlint:enable line_length
  
}

public extension GlobalMessageService {
  
  /// An instance of `GlobalMessageServiceHelper`
  internal static let helper = GlobalMessageServiceHelper()
  
  /// Application key. (read-only)
  public static var applicationKey: String {
    if let applicationKey = helper.applicationKey {
      return applicationKey
    } else {
      fatalError("GlobalMessageService. You should call register() first")
    }
  }
  
  /**
   Registers framework with passed application key and `GlobalMessageServiceGoogleCloudMessagingHelper` 
   with `senderID`
   - Parameter applicationKey: `String` with yours application key
   - Parameter googleCloudMessagingHelper: An instance of `GlobalMessageServiceGoogleCloudMessagingHelper`, 
   to be configured with SenderID, that provedes receiving of push-notifications on a device
   - Parameter googleCloudMessagingSenderID: Yours Google Cloud Messaging SenderID 
   (project number in Google Developer Console)
   */
  public static func register(
    applicationKey applicationKey: String,
    googleCloudMessagingHelper: GlobalMessageServiceGoogleCloudMessagingHelper,
    andGoogleCloudMessagingSenderID googleCloudMessagingSenderID: String) // swiftlint:disable:this line_length
  {
    
    helper.applicationKey = applicationKey
    
    googleCloudMessagingHelper.configure(withSenderID: googleCloudMessagingSenderID)
    
    GlobalMessageService.googleCloudMessagingHelper = googleCloudMessagingHelper
    
  }
  
}
