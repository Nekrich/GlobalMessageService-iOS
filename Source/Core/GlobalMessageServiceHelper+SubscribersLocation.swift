//
//  GlobalMessageServiceHelper+SubscribersLocation.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/24/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

// MARK: - Location update
private extension GlobalMessageServiceHelper {
  
  /// min location update `NSTimeInterval`
  private static let updateInterval: NSTimeInterval = 30 * 60 // 30 minutes
  
  /// `NSDate`, when last location successfully sended to Global Message Services server
  private static var lastUpdateLocation = NSDate(
    timeIntervalSinceNow: -(GlobalMessageServiceHelper.updateInterval * 2))
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter location: `CLLocation` containing subscriber's location. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`,
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  private func updateSubscriberLocation(
    location: CLLocation?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    let timestamp = location?.timestamp ?? NSDate()
    guard timestamp.timeIntervalSinceDate(GlobalMessageServiceHelper.lastUpdateLocation)
      >= GlobalMessageServiceHelper.updateInterval
      else { return }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: GlobalMessageService.registeredGMStoken),
      "latitude": location?.coordinate.latitude ?? NSNull(),
      "longitude": location?.coordinate.longitude ?? NSNull(),
    ]
    
    GMSProvider.sharedInstance.POST("location", parameters: requestParameters) { response in
      
      guard !response.isFailure(completion) else { return }
      
      completion?(.Success(true))
      GlobalMessageServiceHelper.lastUpdateLocation = timestamp
    }
    
  }
  
}

public extension GlobalMessageService {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter location: `CLLocation` containing subscriber's location. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`,
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  public static func updateSubscriberLocation(
    location: CLLocation?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateSubscriberLocation(
      location,
      completionHandler: completionHandlerInMainThread(completion))
    
  }

}
