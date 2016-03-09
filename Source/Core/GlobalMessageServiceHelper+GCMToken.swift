//
//  GlobalMessageServiceHelper+GCMToken.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/24/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - GCM Token
private extension GlobalMessageServiceHelper {
  
  /**
   Updates Google Cloud Messaging token on Global Message Services servers
   
   - parameter token: `String?` containing Google Cloud Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Bool, GlobalMessageServiceError>`,
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  private func updateGCMToken(
    token: String?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    GlobalMessageService.registeredGCMtoken = token
    
    let errorCompletion: (GlobalMessageServiceError) -> Void = { error in
      //self.updateGCMTokenTask = .None
      completion?(.Failure(error))
    }
    
    guard let gcmToken = token else {
      errorCompletion(.GCMTokenIsNotSet)
      return
    }
    
    let device = UIDevice.currentDevice()
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: GlobalMessageService.registeredGMStoken),
      "gcmTokenId"     : gcmToken,
      "device_type"    : device.systemName,
      "device_version" : device.systemVersion
    ]
    
    GMSProvider.sharedInstance.POST("lib_update_token", parameters: requestParameters) { response in
      
      if response.isFailure(completion) {
        return
      }
      
      GlobalMessageService.allowRecievePush(self.settings.authorized) { response in
        completion?(response)
      }
      
    }
  }
  
}

public extension GlobalMessageService {
  
  /**
   Updates Google Cloud Messaging token on Global Message Services servers
   
   - parameter token: `String?` containing Google Cloud Messaging token
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result``<Bool, GlobalMessageServiceError>`,
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  public static func updateGCMToken(
    token: String?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateGCMToken(
      token,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}
