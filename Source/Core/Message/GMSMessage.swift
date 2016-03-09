//
//  GMSMessage.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation

/**
 Compares two `GlobalMessageServiceMessage`s
 - Parameter lhs: frirst `GlobalMessageServiceMessage`
 - Parameter rhs: second `GlobalMessageServiceMessage`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
@warn_unused_result public func == (
  lhs: GlobalMessageServiceMessage,
  rhs: GlobalMessageServiceMessage)
  -> Bool //swiftlint:disable:this opening_brace
{
  return lhs.alphaName == rhs.alphaName
  && lhs.type == rhs.type
  && lhs.id == rhs.id
  && lhs.deliveredDate.timeIntervalSinceReferenceDate == rhs.deliveredDate.timeIntervalSinceReferenceDate
}

/**
 `Struct` representing delivered message to subscriber
 */
public struct GlobalMessageServiceMessage: Hashable {
  
  /**
   `String` representing senders alpha name. Can be `nil`
   */
  public let alphaName: String
  
  /**
   `String` representing message body. Can be `nil`
   */
  public let message: String
  
  /**
   Message delivered `NSDate`
   */
  public let deliveredDate: NSDate
  
  /**
   Message type
   - SeeAlso: `GlobalMessageServiceMessageType` for details
   */
  public let type: GlobalMessageServiceMessageType
  
  /**
   `UInt64` Global Message Services message id
   */
  public let id: UInt64 // swiftlint:disable:this variable_name
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `GlobalMessageServiceMessage` from `GMSInboxMessage`
   - Parameter message: `GMSInboxMessage` object
   - Returns: Converted object from `GMSInboxMessage` if successfully converted, `nil` otherwise
   */
  internal init?(message: GMSInboxMessage) {
    // swiftlint:enable valid_docs
    guard let type = GlobalMessageServiceMessageType(rawValue: message.type) else {
      return nil
    }
    
    if message.fetchedDate?.to != GlobalMessageService.registeredUserPhone {
      return nil
    }
    
    self.alphaName     = message.getAlphaNameString()
    self.message       = message.message ?? ""
    self.id            = message.messageID?.unsignedLongLongValue ?? 0
    
    self.deliveredDate = NSDate(timeIntervalSinceReferenceDate: message.deliveredDate)
    
    self.type          = type
    
  }
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `GlobalMessageServiceMessage` from `GlobalMessageServicePushNotification`
   - Parameter pushNotification: `GlobalMessageServicePushNotification` object
   - Returns: Converted object from `GlobalMessageServicePushNotification` if successfully converted, 
   `nil` otherwise
  */
  public init(pushNotification: GlobalMessageServicePushNotification) {
    // swiftlint:enable valid_docs
    self.alphaName     = pushNotification.alphaName
    self.message       = pushNotification.body ?? ""
    self.id            = pushNotification.gmsMessageID
    
    self.deliveredDate = pushNotification.deliveredDate
    
    self.type          = .PushNotification
  }
  
  // swiftlint:disable valid_docs
  /**
   Initializes a new instance of `GlobalMessageServiceMessage` from `[String: AnyObject]`
   - Parameter dictionary: Dictionary<String, AnyObject> describing message
   - Returns: Converted object from ` Dictionary<String, AnyObject>` if successfully converted, 
   `nil` otherwise
   */
  internal init?(
    // swiftlint:enable valid_docs

    dictionary: Dictionary<String, AnyObject>,
    andType type: GlobalMessageServiceMessageType) // swiftlint:disable:this opening_brace
  {
    
    guard let
      from = dictionary["from"] as? String,
      to = dictionary["to"] as? Double,
      message = dictionary["message"] as? String,
      id = dictionary["msg_uniq_id"] as? Double,
      deliveredTimeStamp = dictionary["deliveredDate"] as? Double
      else  // swiftlint:disable:this opening_brace
    {
      return nil
    }
    
    if Int64(to) != GlobalMessageService.registeredUserPhone {
      return nil
    }
    
    self.alphaName     = from
    //self.to            = UInt64(to)
    self.message       = message
    self.id            = UInt64(id)
    
    self.deliveredDate = NSDate(timeIntervalSince1970: deliveredTimeStamp / 1000.0)
    
    self.type          = type
    
  }
  
  public var hashValue: Int {
    return "\(alphaName)\(deliveredDate.timeIntervalSinceReferenceDate)\(id)\(type.rawValue)".hash
  }
  
  public func delete() -> Bool {
    let predicate = NSPredicate(
      format: "messageID == %@ && deliveredDate == %@ && type == \(type.rawValue)",
      NSDecimalNumber(unsignedLongLong: id),
      deliveredDate)//,
      //NSNumber(short: ))
    let moc = GlobalMessageServiceCoreDataHelper.newManagedObjectContext()
    if let message = GMSInboxMessage.findObject(
      withPredicate: predicate,
      inManagedObjectContext: moc,
      createNewIfNotFound: false) as? GMSInboxMessage {
      message.deletionMark = true
      
      let result = moc.saveSafeRecursively()
      switch result {
      case .Failure(_):
        return false
      default:
        return true
      }
    }
    return false
  }
  
}
