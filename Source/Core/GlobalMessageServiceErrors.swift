//
//  GlobalMessageServiceErrors.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation

/// Object containing the localized description of `self`
public protocol CustomLocalizedDescriptionConvertible {
  /// A string containing the localized description of the object. (read-only)
  var localizedDescription: String { get }
}

// MARK: - GlobalMessageServiceError
/**
 Enum represents GlobalMessageService framework errors
 
 - RequestError: A HTTP request error. Contains `GlobalMessageServiceError.Request`
 - ResultParsingError: An error occured when parsing result. Contains 
`GlobalMessageServiceError.ResultParsing`
 - AddSubscriberError: An error occured when adding new subscriber. 
Contains `GlobalMessageServiceError.AddSubscriber`
 - AnotherTaskInProgressError: Another task in progress error. 
Contains `GlobalMessageServiceError.AnotherTaskInProgress`
 - MessageFetcherError: Error occurred when retrieving messages. Contains 
`GlobalMessageServiceError.MessageFetcher`
 - GMSTokenIsNotSet: Global Message Service token is not set
 - GCMTokenIsNotSet: Google Cloud Messaging token is not set
 - NoPhoneOrEmailPassed: No phone or e-mail is passed
 - UnknownError: An unknown error occurred
 */
public enum GlobalMessageServiceError: ErrorType {
  
  /// A HTTP request error. Contains `GlobalMessageServiceError.Request`
  case RequestError(Request)
  
  /// An error occured when parsing result. Contains `GlobalMessageServiceError.ResultParsing`
  case ResultParsingError(ResultParsing)
  
  /// An error occured when adding new subscriber. Contains `GlobalMessageServiceError.AddSubscriber`
  case AddSubscriberError(AddSubscriber)
  
  /// Another task in progress error. Contains `GlobalMessageServiceError.AnotherTaskInProgress`
  case AnotherTaskInProgressError(AnotherTaskInProgress)
  
  /// Error occurred when retrieving messages. Contains `GlobalMessageServiceError.MessageFetcher`
  case MessageFetcherError(MessageFetcher)
  
  /// Global Message Service token is not set
  case GMSTokenIsNotSet
  
  /// Google Cloud Messaging token is not set
  case GCMTokenIsNotSet
  
  /// An unknown error occurred
  case NotAuthorized
  
  /// No phone or e-mail is passed
  case NoPhoneOrEmailPassed
  
  /// An unknown error occurred
  case UnknownError
  
  /// A string containing the localized **template** of the object. (read-only)
  private var localizedTemplate: String {
    let enumPresentation: String
    switch self {
    case RequestError(let error):
      enumPresentation = error.localizedTemplate
      break
    case ResultParsingError(let error):
      enumPresentation = error.localizedTemplate
      break
    case AddSubscriberError(let error):
      enumPresentation = error.localizedTemplate
      break
    case AnotherTaskInProgressError(let error):
      enumPresentation = error.localizedTemplate
      break
    case MessageFetcherError(let error):
      enumPresentation = error.localizedTemplate
      break
    default:
      enumPresentation = "\(self)"
      break
    }
    return GlobalMessageService.bundle.localizedStringForKey(
      "GlobalMessageServiceError.\(enumPresentation)",
      value: .None,
      table: "GlobalMessageServiceErrors")
  }
  
  /// A string containing the localized description of the object. (read-only)
  public var localizedDescription: String {
    let localizedString: String
    switch self {
    case RequestError(let error):
      localizedString = error.localizedDescription
      break
    case ResultParsingError(let error):
      localizedString = error.localizedDescription
      break
    case AddSubscriberError(let error):
      localizedString = error.localizedDescription
      break
    case AnotherTaskInProgressError(let error):
      localizedString = error.localizedDescription
      break
    case MessageFetcherError(let error):
      localizedString = error.localizedDescription
      break
    default:
      localizedString = localizedTemplate
      break
    }
    return localizedString
  }
}

// MARK: - GlobalMessageServiceError.AnotherTaskInProgress
public extension GlobalMessageServiceError {
  
  /**
   Enum represents errors occured when you trying launch
   
   - AddSubscriber: Adding new subscriber
   - UpdateSubscriber: Updating subscriber's info
   - UpdateGCMToken: Updating Google Cloud Messaging token
   */
  public enum AnotherTaskInProgress: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Adding new subscriber
    case AddSubscriber
    
    /// Updating subscriber's info
    case UpdateSubscriber
    
    /// Updating Google Cloud Messaging token
//    case UpdateGCMToken
    
    /// A string containing the localized **template** of the object. (read-only)
    private var localizedTemplate: String {
      let enumPresentation: String = "\(self)"
      return GlobalMessageService.bundle.localizedStringForKey(
        "AnotherTaskInProgress.\(enumPresentation)",
        value: .None,
        table: "GlobalMessageServiceErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
    
  }
  
}

// MARK: - GlobalMessageServiceError.AddSubscriber
public extension GlobalMessageServiceError {
  
  /**
   Enum represents response errors occured when adding new subscriber
   
   - NoAppDeviceId: There is no expexted `uniqAppDeviceId` field in response data
   - AppDeviceIdWrondType: Can't convert recieved `uniqAppDeviceId` to `UInt64`
   - AppDeviceIdLessOrEqualZero: Recieved `uniqAppDeviceId` is `0` or less
   */
  public enum AddSubscriber: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// here is no expexted `uniqAppDeviceId` field in response data
    case NoAppDeviceId
    
    /// Can't convert recieved `uniqAppDeviceId` to `UInt64`
    case AppDeviceIdWrondType
    
    /// Recieved `uniqAppDeviceId` is `0` or less
    case AppDeviceIdLessOrEqualZero
    
    /// A string containing the localized **template** of the object. (read-only)
    private var localizedTemplate: String {
      let enumPresentation: String = "\(self)"
      return GlobalMessageService.bundle.localizedStringForKey(
        "AddSubscriber.\(enumPresentation)",
        value: .None,
        table: "GlobalMessageServiceErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
    
  }
  
}

// MARK: - GlobalMessageServiceError.ResultParsing
public extension GlobalMessageServiceError {
  
  /**
   Enum represents response parsing errors
   
   - CantRepresentResultAsDictionary: Request returned response `NSData`, 
   that can't be represented as `[String: AnyObject]`
   - NoStatus: There is no expexted `status` flag in response data
   - StatusIsFalse: `status` flag in response data is `false`. 
   Contains `String?` - description of error, that occurred on a remote server
   - UnknownError: Unknown error occurred when parsing response
   */
  public enum ResultParsing: ErrorType, CustomLocalizedDescriptionConvertible {
    /// Request returned response `NSData`, that can't be represented as `[String: AnyObject]`
    case CantRepresentResultAsDictionary
    
    /// There is no expexted `status` flag in response data
    case NoStatus
    
    /**
     `status` flag in response data is `false`. Contains `String?` - description of error, 
     that occurred on a remote server
     */
    case StatusIsFalse(String?)
    
    /// Unknown error occurred when parsing response
    case UnknownError
    
    /// A string containing the localized **template** of the object. (read-only)
    private var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case StatusIsFalse:
        enumPresentation = "StatusIsFalse"
        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return GlobalMessageService.bundle.localizedStringForKey(
        "ResultParsing.\(enumPresentation)",
        value: .None,
        table: "GlobalMessageServiceErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case StatusIsFalse(let errorString):
        localizedString = String(format: localizedTemplate, errorString ?? "")
        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
  
}

// MARK: - GlobalMessageServiceError.Request
public extension GlobalMessageServiceError {
  
  /**
   Enum represents request errors
   
   - Error: Request failed. Contains a pointer to `NSError` object.
   - UnknownError: Request failed but there is no any represenative error
   */
  public enum Request: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Request failed. Contains a pointer to `NSError` object.
    case Error(NSError)
    
    /// Request failed but there is no any represenative error
    case UnknownError
    
    /// A string containing the localized **template** of the object. (read-only)
    private var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case Error:
        enumPresentation = "Error"
        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return GlobalMessageService.bundle.localizedStringForKey(
        "Request.\(enumPresentation)",
        value: .None,
        table: "GlobalMessageServiceErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case Error(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
  
}

// MARK: - GlobalMessageServiceError.MessageFetcher
public extension GlobalMessageServiceError {
  
  /**
   Enum represents errors occurred when retrieving messages
   
   - NoPhone: Subscribers profile has no phone number
   - CoreDataSaveError(NSError): An error occurred while saving new messages. 
   Contains a pointer to `NSError` object.
   */
  public enum MessageFetcher: ErrorType, CustomLocalizedDescriptionConvertible {
    
    /// Subscribers profile has no phone number
    case NoPhone
    
    /// An error occurred while saving new messages. Contains a pointer to `NSError` object.
    case CoreDataSaveError(NSError)
    
    /// A string containing the localized **template** of the object. (read-only)
    private var localizedTemplate: String {
      let enumPresentation: String
      switch self {
      case CoreDataSaveError:
        enumPresentation = "CoreDataSaveError"
        break
      default:
        enumPresentation = "\(self)"
        break
      }
      return GlobalMessageService.bundle.localizedStringForKey(
        "MessageFetcher.\(enumPresentation)",
        value: .None,
        table: "GlobalMessageServiceErrors")
    }
    
    /// A string containing the localized description of the object. (read-only)
    public var localizedDescription: String {
      let localizedString: String
      switch self {
      case CoreDataSaveError(let error):
        localizedString = String(format: localizedTemplate, error.localizedDescription)
        break
      default:
        localizedString = localizedTemplate
        break
      }
      return localizedString
    }
  }
}
