//
//  GlobalMessageServiceHelper+Validation.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 3/28/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import Alamofire

internal extension GlobalMessageServiceHelper {

  /**
   Checks if there no mutually exclusive tasks
   
   - parameter checkGMStoken: `Bool` indicates to check Global Message Services device token is set, or not
   - parameter completion: closure to execute, if checks not passed
   - returns: `true` if all checks passed, `false` otherwise
   */
  internal func canPreformAction<T>(
    checkGMStoken: Bool,
    _ completion: ((Result<T, GlobalMessageServiceError>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    let errorCompletion: (GlobalMessageServiceError.AnotherTaskInProgress) -> Void = { error in
      completion?(.Failure(.AnotherTaskInProgressError(error)))
      return
    }
    
    if addSubscriberTask != nil {
      errorCompletion(.AddSubscriber)
      return false
    }
    
    if updateSubscriberInfoTask != nil {
      errorCompletion(.UpdateSubscriber)
      return false
    }
    
    if checkGMStoken && GlobalMessageService.registeredGMStoken <= 0 {
      completion?(.Failure(.GMSTokenIsNotSet))
      return false
    }
    
    return true
    
  }

  /**
   Validates email and phone number
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   
   - returns: `true` if email or phone is setted and not empty, `false` otherwise.
   Executes `completionHandler` on `false`
   */
  func validateEmail(
    email: String?,
    phone: Int64?)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    /// Email is empty
    let emailIsEmpty: Bool
    if let email = email {
      if email.isEmpty {
        emailIsEmpty = true
      } else {
        emailIsEmpty = false
      }
    } else {
      emailIsEmpty = true
    }
    
    // Phone is not valid
    let phoneNumberIsEmpty: Bool
    if let phone = phone {
      if phone < 1 {
        phoneNumberIsEmpty = true
      } else {
        phoneNumberIsEmpty = false
      }
    } else {
      phoneNumberIsEmpty = true
    }
    
    if emailIsEmpty && phoneNumberIsEmpty {
      return false
    }
    
    return true
  }
  
  /**
   Validates email and phone number
   
   - parameter email: `String` containing subscriber's e-mail address
   - parameter phone: `Int64?` containing subscriber's phone number. Can be `nil`
   - parameter completionHandler: The code to be executed when validation failed. (optional).
   This block takes no parameters. Returns `Result` `<T, GlobalMessageServiceError>`
   
   - returns: `true` if email or phone is setted and not empty, `false` otherwise.
   Executes `completionHandler` on `false`
   */
  func validateEmail<T>(
    email: String?,
    phone: Int64?,
    completionHandler completion: ((Result<T, GlobalMessageServiceError>) -> Void)?)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    if !validateEmail(email, phone: phone) {
      completion?(.Failure(.NoPhoneOrEmailPassed))
      return false
    }
    
    return true
  }
  
}
