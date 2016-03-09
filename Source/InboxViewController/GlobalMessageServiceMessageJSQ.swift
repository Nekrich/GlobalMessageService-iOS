//
//  GlobalMessageServiceMessageJSQ.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/29/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import JSQMessagesViewController

/**
 `JSQMessageData` wrapper for `GlobalMessageServiceMessage`
 */
public class GlobalMessageServiceMessageJSQ: NSObject, JSQMessageData {
  
  /**
   An instance of `GlobalMessageServiceMessage`
   */
  let message: GlobalMessageServiceMessage
  
  /**
   Initlizes `self` with `GlobalMessageServiceMessage` object
   - Parameter message: `GlobalMessageServiceMessage` object to initialize with
   */
  init(message: GlobalMessageServiceMessage) {
    self.message = message
  }
  
  /**
   `String` representing senders alpha name. Can be `nil`
   */
  var alphaName: String {
    return message.alphaName
  }
  
  /**
   - Returns: A string identifier that uniquely identifies the user who sent the message.
   *
   *  @discussion If you need to generate a unique identifier, consider using
   *  `[[NSProcessInfo processInfo] globallyUniqueString]`
   *
   *  @warning You must not return `nil` from this method. This value must be unique.
   */
  public func senderId() -> String! {
    return message.alphaName
  }
  
  /**
   - Returns: The display name for the user who sent the message.
   *
   *  @warning You must not return `nil` from this method.
   */
  public func senderDisplayName() -> String! {
    return message.alphaName
  }
  
  /**
   The date that the message was delivered
   - Returns: The date that the message was sent.
   */
  public func date() -> NSDate! {
    return message.deliveredDate
  }
  
  /**
   This method is used to determine if the message data item contains text or media.
   If this method returns `YES`, an instance of `JSQMessagesViewController` will ignore
   the `text` method of this protocol when dequeuing a `JSQMessagesCollectionViewCell`
   and only call the `media` method.
   
   Similarly, if this method returns `NO` then the `media` method will be ignored and
   and only the `text` method will be called.
   
   - Returns: A boolean value specifying whether or not this is a media message or a text message.
   Return `YES` if this item is a media message, and `NO` if it is a text message.
   */
  public func isMediaMessage() -> Bool {
    return false
  }
  
  /**
   An integer that can be used as a table address in a hash table structure.
   - Returns: An integer that can be used as a table address in a hash table structure.
   
   - Note: This value must be unique for each message with distinct contents.
   This value is used to cache layout information in the collection view.
   */
  public func messageHash() -> UInt {
    return UInt(abs(message.hashValue))
  }
  
  /**
   `String` representing message body. Can be `nil`
   - Returns: `String` representing message body. Can be `nil`
   */
  public func text() -> String! {
    return message.message
  }
  
  /**
   Message type
   - Returns: Message type
   - SeeAlso: `GlobalMessageServiceMessageType` for details
   */
  public var type: GlobalMessageServiceMessageType {
    return message.type
  }
  
}

/**
 Compares two `GlobalMessageServiceMessageJSQ`s
 - Parameter lhs: frirst `GlobalMessageServiceMessageJSQ`
 - Parameter rhs: second `GlobalMessageServiceMessageJSQ`
 - Returns: `true` if both messages are equal, otherwise returns `false`
 */
func == (lhs: GlobalMessageServiceMessageJSQ, rhs: GlobalMessageServiceMessageJSQ) -> Bool {
  return lhs.message == rhs.message
}
