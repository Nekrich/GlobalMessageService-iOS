//
//  GlobalMessageServiceMessageFetcherJSQ.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 2/29/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation
import UIKit

/**
 The delegate of a `GlobalMessageServiceMessageFetcherJSQ` object must adopt the 
 `GlobalMessageServiceMessageFetcherJSQDelegate` protocol.
 Delegate object must implement `newMessagesFetched()` method
 */
internal protocol GlobalMessageServiceMessageFetcherJSQDelegate: class {
  /**
   Calls when new remote push-notification delivered
   */
  func newMessagesFetched()
}

/**
 Message fetcher for `JSQViewController`
 */
internal class GlobalMessageServiceMessageFetcherJSQ {
  /**
   Shared `GlobalMessageServiceMessageFetcherJSQ` object.
  */
  static let sharedInstance = GlobalMessageServiceMessageFetcherJSQ()
  
  /**
   Delegate
   */
  internal weak var delegate: GlobalMessageServiceMessageFetcherJSQDelegate? = .None
  
  /// Private initializer
  private init() {
    GlobalMessageService.helper.internalRemoteNotificationsDelegate = self
    NSFileManager.defaultManager()
  }
  
  /// Earliest fetched date
  private var lastFetchedDate = NSDate(timeInterval: -0.001, sinceDate: NSDate().startOfDay())
  
  /// Fetched `GlobalMessageServiceMessageJSQ` messages
  internal private (set) var messages = [GlobalMessageServiceMessageJSQ]()
  
  /// OTTBulkPlatform launched date
  private let ottPlatformLaunchDate = NSDate(timeIntervalSinceReferenceDate: 473299200)
  
  /// Retuns `true` if can fetch more erlier messages, `false othrewise`
  internal var hasMorePrevious: Bool {
    return lastFetchedDate.timeIntervalSinceReferenceDate > minLastFetchedDate.timeIntervalSinceReferenceDate
  }
  
  /**
   Returns minimum available `NSDate` to fetch earlier messages
   - Returns: minimum available `NSDate` to fetch earlier messages
   */
  private var minLastFetchedDate: NSDate {
    let minLastFetchedDate =
      GlobalMessageService.registeredUser?.registrationDate
      ?? ottPlatformLaunchDate
    
    return minLastFetchedDate
  }
  
  /** 
   Fetching todays messages (with delivered date is today)
   - Parameter fetch: `Bool` indicates to fetch message from remote server if no stored data available.
   `true` - fetch data if there is no cached data, `false` otherwise. Default value is `true`
   - Parameter completionHandler: Closure to run, when messages fetched. Retunrs `Bool` flag, that has value 
   `true` if new messages has been fateched, `false` otherwiswe
   */
  internal func fetchTodaysMessages(fetch: Bool = true, completionHandler: (Bool) -> Void) {
    
    let completion = completionHandlerInMainThread(completionHandler)
    
    GlobalMessageServiceMessagesFetcher.fetchMessages(forDate: NSDate(), fetch: fetch) { [weak self] result in
      
      guard let sSelf = self,
        let todaysMessages = result.value where !todaysMessages.isEmpty else {
        completion(false)
        return
      }
      
      let newMessages = todaysMessages
        .sort {
          return $0.deliveredDate.timeIntervalSinceReferenceDate
            > $1.deliveredDate.timeIntervalSinceReferenceDate
        }
        .map {
          GlobalMessageServiceMessageJSQ(message: $0)
      }
      
      var newMessagesFetched = false
      synchronized(sSelf.messages) {
        var messages = sSelf.messages
        newMessages.forEach { (message) in
          if messages.indexOf({ return $0.message == message.message }) == .None {
            messages.append(message)
            newMessagesFetched = true
          }
        }
        
        sSelf.messages = messages.sort {
          return $0.date().timeIntervalSinceReferenceDate < $1.date().timeIntervalSinceReferenceDate
        }
        
      }
      
      completion(newMessagesFetched)
      
    }
  }
  
  /**
   `Bool` flag, that has value `true` if there are fetch messages job is active, `false` otherwise 
   */
  private var fetchingPreviousMessages: Bool = false
  
  /**
   Fetching previous messages
   - Parameter completionHandler: Closure to run, when messages fetched
   */
  internal func loadPrevious(completionHandler: () -> Void) {
    if fetchingPreviousMessages {
      return
    }
    fetchingPreviousMessages = true
    
    let completion = { [weak self] in
      self?.fetchingPreviousMessages = false
      completionHandlerInMainThread(completionHandler)()
    }
    
    loadPreviousMessages(completion)
  }
  
  /**
   Fetching previous messages (private)
   - Parameter completion: Closure to run, when messages fetched
   */
  private func loadPreviousMessages(completion: () -> Void) {
    let lastFetchedDate = self.lastFetchedDate
    
    GlobalMessageServiceMessagesFetcher.fetchMessages(forDate: lastFetchedDate) { [weak self] result in
      guard let sSelf = self else { return }
      guard var messages = result.value else {
        completion()
        return
      }
      
      if messages.isEmpty {
        sSelf.lastFetchedDate = lastFetchedDate.previousDay()
        if sSelf.hasMorePrevious {
          sSelf.loadPreviousMessages(completion)
        } else {
          completion()
        }
        return
      }
      
      messages
        .sortInPlace {
          return $0.deliveredDate.timeIntervalSinceReferenceDate
            > $1.deliveredDate.timeIntervalSinceReferenceDate
        }
      
      synchronized(sSelf) {
        messages.forEach {
          sSelf.messages.insert(GlobalMessageServiceMessageJSQ(message: $0), atIndex: 0)
        }
        sSelf.lastFetchedDate = lastFetchedDate.previousDay()
      }
      
      
      completion()
      
    }
  }
  
  /**
   Remove and return the element at `index`
   - Parameter index: index of element to delete
   - Returns: deleted element at `index`, or `nil` if index is out of bounds
   */
  func delete(index: Int) -> GlobalMessageServiceMessageJSQ? {
    if messages.count > index && index >= 0 {
      let deletedValue = messages.removeAtIndex(index)
      deletedValue.message.delete()
    }
    return .None
  }
}

extension GlobalMessageServiceMessageFetcherJSQ: GlobalMessageServiceRemoteNotificationReciever {
  
  func didReceiveRemoteNotification(
    userInfo: [NSObject : AnyObject],
    pushNotification: GlobalMessageServicePushNotification?) // swiftlint:disable:this opening_brace
  {
    
    if let pushNotification = pushNotification {
      let message = GlobalMessageServiceMessage(pushNotification: pushNotification)
      messages.append(GlobalMessageServiceMessageJSQ(message: message))
      delegate?.newMessagesFetched()
//    messages
//      .sort {
//        return $0.date().timeIntervalSinceReferenceDate
//          > $1.date().timeIntervalSinceReferenceDate
//    }
    }
  }
  
}
