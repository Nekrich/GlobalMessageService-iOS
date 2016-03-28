//
//  GlobalMessageService+Registration.swift
//  Pods
//
//  Created by Vitalii Budnik on 12/14/15.
//
//

import Foundation
import Alamofire

/** Makes pased clousure running in main thread
 - Parameter completion: async closure that must be runned in main thread later
 - Returns: Wrapped closure that will executed asynchronously in the main thread
 */
internal func completionHandlerInMainThread<T>(completion: ((T) -> Void)?) -> (T -> Void)? {
  if let completion = completion {
    return { result in
      dispatch_async(dispatch_get_main_queue()) {
        completion(result)
      }
    }
  } else {
    return .None
  }
}

/** 
 Makes pased clousure running in main thread
 Returns Wrapped closure that will executed asynchronously in the main thread
 - Parameter completion: async closure that must be runned in main thread later
 - Returns: Wrapped closure that will executed asynchronously in the main thread
 */
internal func completionHandlerInMainThread<T>(completion: (T) -> Void) -> (T -> Void) {
  return { result in
    dispatch_async(dispatch_get_main_queue()) {
      completion(result)
    }
  }
}

// MARK: - Subscriber Info
private extension GlobalMessageServiceHelper {
  
  /**
   Updates subscriber's info on Global Message Services servers
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`, 
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  private func updateSubscriberInfo(
    email email: String?,
    phone: Int64?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(true, completion) {
      return
    }
    
    let phoneNSNumber: NSNumber?
    if let phone = phone {
      phoneNSNumber = NSNumber(longLong: phone)
    } else {
      phoneNSNumber = .None
    }
    
    let email = email ?? ""
    
    if !validateEmail(email, phone: phone, completionHandler: completion) {
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: GlobalMessageService.registeredGMStoken),
      "phone": phoneNSNumber ?? NSNull(),
      "email": email.isEmpty ? NSNull() : email
    ]
    
    updateSubscriberInfoTask = GMSProvider.sharedInstance.POST(
      "lib_update_phone_email",
      parameters: requestParameters) { response in
        
        if GlobalMessageService.registeredUser?.phone != phone {
          GlobalMessageServiceCoreDataHelper.managedObjectContext.deleteObjectctsOfAllEntities()
        }
        
        guard let _: [String: AnyObject] = response.result.value else {
          self.updateSubscriberInfoTask = .None
          completion?(.Failure(response.result.error ?? .UnknownError))
          return
        }
        
        GlobalMessageService.registeredUser = GlobalMessageServicesSubscriber(withEmail: email, phone: phone)
        
        self.updateSubscriberInfoTask = .None

        completion?(.Success(true))
        
    }
  }
  
  /**
   Adds a new subscriber on Global Message Services servers
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<UInt64, GlobalMessageServiceError>`, 
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred, 
   otherwise see `result.error`
   */
  private func addSubscriber(
    email email: String?,
    phone: Int64?,
    completionHandler completion: ((Result<UInt64, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(completion) {
      return
    }
    
    let gcmToken = GlobalMessageService.registeredGCMtoken ?? ""
    
    let device = UIDevice.currentDevice()
    
    let phoneNSNumber: NSNumber?
    if let phone = phone {
      phoneNSNumber = NSNumber(longLong: phone)
    } else {
      phoneNSNumber = .None
    }
    
    let email = email ?? ""
    
    if !validateEmail(email, phone: phone, completionHandler: completion) {
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNull(),
      "phone": phoneNSNumber ?? NSNull(),
      "email": email.isEmpty ? NSNull() : email,
      "gcmTokenId":  gcmToken.isEmpty ? NSNull() : gcmToken,
      "device_type": device.systemName,
      "device_version": device.systemVersion
    ]
    
    addSubscriberTask = GMSProvider.sharedInstance.POST(
      "lib_add_abonent",
      parameters: requestParameters) { response in
        
        guard let json: [String: AnyObject] = response.result.value else {
          self.addSubscriberTask = .None
          completion?(.Failure(response.result.error ?? .UnknownError))
          return
        }
        
        guard let uniqAppDeviceId = json["uniqAppDeviceId"] else {
          completion?(.Failure(.AddSubscriberError(.NoAppDeviceId)))
          return
        }
        
        guard let newGMSDeviceID = uniqAppDeviceId as? Double else {
          completion?(.Failure(.AddSubscriberError(.AppDeviceIdWrondType)))
          return
        }
        
        if newGMSDeviceID <= 0 {
          completion?(.Failure(.AddSubscriberError(.AppDeviceIdLessOrEqualZero)))
          return
        }
        
        GlobalMessageService.registeredGMStoken = UInt64(newGMSDeviceID)
        GlobalMessageService.registeredUser = GlobalMessageServicesSubscriber(withEmail: email, phone: phone)
        GlobalMessageService.authorized = true
        
        self.addSubscriberTask = .None
        
        self.getSubscribersProfile(completionHandler: completion)
        
    }
    
  }
  
  /**
   Gets subscriber's information from Global Message Services servers
   
   - parameter completionHandler: The code to be executed once the request has finished. (optional).
   This block takes no parameters. Returns `Result` `<UInt64, GlobalMessageServiceError>`,
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred,
   otherwise see `result.error`
   */
  private func getSubscribersProfile(
    completionHandler completion: ((Result<UInt64, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    if !canPreformAction(true, completion) {
      return
    }
    
    let gmsToken = NSNumber(unsignedLongLong: GlobalMessageService.registeredGMStoken)
    
    GMSProvider.sharedInstance.POST(
      "get_profile",
      parameters: ["uniqAppDeviceId":gmsToken]) { response in
        
        guard let json = response.result.value else {
          completion?(.Success(GlobalMessageService.registeredGMStoken))
          return
        }
        
        if let createdDate = json["created_date"] as? Double {
          var user = GlobalMessageService.registeredUser
          user?.registrationDate = NSDate(
            timeIntervalSince1970: createdDate / 1000.0)
          GlobalMessageService.registeredUser = user
          GlobalMessageService.helper.settings.save()
        }
        
        completion?(.Success(GlobalMessageService.registeredGMStoken))
    }
  }
  
}

internal extension GlobalMessageServiceHelper {
  
  /**
   Checks if there no mutually exclusive tasks
   
   - parameter completion: closure to execute, if checks not passed
   - returns: `true` if all checks passed, `false` otherwise
   */
  private func canPreformAction<T>(
    completion: ((Result<T, GlobalMessageServiceError>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    return canPreformAction(false, completion)
  }
  	
}

// MARK: - Allow receive remote push-notifications
private extension GlobalMessageServiceHelper {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter allowPush: `Bool`. `true` - allow recieve remote push notification, 
   `false` - deny recieve remote push notification
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`, 
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  private func allowRecievePush(
    allowPush: Bool,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    if !canPreformAction(completion) {
      return
    }
    
    let errorCompletion: (GlobalMessageServiceError) -> Void = { error in
      completion?(.Failure(error))
    }
    
    if GlobalMessageService.registeredGMStoken <= 0 {
      errorCompletion(.GMSTokenIsNotSet)
      return
    }
    
    let requestParameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: GlobalMessageService.registeredGMStoken),
      "push_allowed": NSNumber(int: allowPush ? 1 : 0)
    ]
    
    let _ = GMSProvider.sharedInstance.POST(
      "lib_alow_recieve_push",
      parameters: requestParameters) { response in
        
        if response.isFailure(completion) {
          return
        }
        
        completion?(.Success(true))
    }
    
  }
  
}

// MARK: - GlobalMessageService Facade
public extension GlobalMessageService {
  
  /**
   Updates subscriber's location on Global Message Services servers
   
   - parameter allowPush: `Bool`. `true` - allow recieve remote push notification, 
   `false` - deny recieve remote push notification
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`, 
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  public static func allowRecievePush(
    allowPush: Bool,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.allowRecievePush(
      allowPush,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
    
  /**
   Adds a new subscriber on Global Message Services servers
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<UInt64, GlobalMessageServiceError>`, 
   where `result.value` contains `UInt64` Global Message Services device token if there no error occurred, 
   otherwise see `result.error`
   */
  public static func addSubscriber(
    email email: String?,
    phone: Int64?,
    completionHandler completion: ((Result<UInt64, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.addSubscriber(
      email: email,
      phone: phone,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
  /**
   Updates subscriber's info on Global Message Services servers
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   - parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. Returns `Result` `<Bool, GlobalMessageServiceError>`, 
   where `result.value` is always `true` if there no error occurred, otherwise see `result.error`
   */
  public static func updateSubscriberInfo(
    email email: String?,
    phone: Int64?,
    completionHandler completion: ((Result<Bool, GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    helper.updateSubscriberInfo(
      email: email,
      phone: phone,
      completionHandler: completionHandlerInMainThread(completion))
    
  }
  
}
