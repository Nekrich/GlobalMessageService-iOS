//
//  GMSMessageFetcher.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/25/16.
//
//

import Foundation
import CoreData
import Alamofire

/**
 `Class` fetches delivered messages from Global Message Services servers
 */
public final class GlobalMessageServiceMessagesFetcher {
  
  /// Private initializer
  private init() {
    
  }
  
  /**
   Fetches messages from Global Message Services servers
   - Parameter date: `NSDate` concrete date for which you need to get messages
   - Parameter fetch: `Bool` indicates to fetch message from remote server if no stored data available.
   `true` - fetch data if there is no cached data, `false` otherwise. Default value is `true`
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
  This block takes no parameters. 
  Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
  is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  public class func fetchMessages(
    forDate date: NSDate,
    fetch: Bool = true,
    completionHandler: ((Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void)? = .None) // swiftlint:disable:this line_length
  {
    
    let completion = completionHandlerInMainThread(completionHandler)
    
    if !GlobalMessageService.authorized {
      completion?(.Failure(.NotAuthorized))
    }
    
    if date.timeIntervalSinceReferenceDate > NSDate().timeIntervalSinceReferenceDate {
      completion?(.Success([]))
    }
    
    let lastFetchedTimeInterval: NSTimeInterval
    
//    let completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void = { result in
//      if let completionHandler = completionHandler {
//        dispatch_async(dispatch_get_main_queue()) {
//          completionHandler(result)
//        }
//      }
//    }
    
    let gmsMessages: [GlobalMessageServiceMessage]
    if let fetchedDate = GMSInboxFetchedDate.getInboxFetchedDate(
      forDate: date.timeIntervalSinceReferenceDate) // swiftlint:disable:this opening_brace
    {
      let messages: [GMSInboxMessage]
      // swiftlint:disable empty_count
      if let fetchedMessages = fetchedDate.messages where fetchedMessages.count > 0 {
        // swiftlint:enable empty_count
        messages = fetchedMessages.allObjects as? [GMSInboxMessage] ?? []
      } else {
        messages = []
      }
      gmsMessages = messages
        .filter({!$0.deletionMark})
        .flatMap() { GlobalMessageServiceMessage(message: $0) }
      
      if fetchedDate.lastMessageDate == date.endOfDay().timeIntervalSinceReferenceDate {
        completion?(.Success(gmsMessages))
        return
      }
      lastFetchedTimeInterval = fetchedDate.lastMessageDate
    } else {
      gmsMessages = []
      lastFetchedTimeInterval = date.startOfDay().timeIntervalSinceReferenceDate
    }
    
    if !fetch {
      completion?(.Success(gmsMessages))
      return
    }
    
    fetchSMS(forDate: lastFetchedTimeInterval) { result in
      
      guard let sms: [GlobalMessageServiceMessage] = result.value(completionHandler) else {
        return
      }
      
      GlobalMessageServiceMessagesFetcher.fetchViber(forDate: lastFetchedTimeInterval) { result in
        
        guard let viber = result.value(completionHandler) else {
          return
        }
        
        GlobalMessageServiceMessagesFetcher.fetchPushNotifications(
          forDate: lastFetchedTimeInterval) { result in
            
            guard let push = result.value(completionHandler) else {
              return
            }
            
            completion?(.Success(gmsMessages + sms + viber + push))
        }
      }
    }
  }
  
  /**
   Fetches `.Viber` messages from Global Message Services servers
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchViber(
    forDate date: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void) // swiftlint:disable:this line_length
  {
    fetch(.Viber, date: date, completionHandler: completion)
  }
  
  /**
   Fetches `.SMS` messages from Global Message Services servers
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchSMS(
    forDate date: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void) // swiftlint:disable:this line_length
  {
    fetch(.SMS, date: date, completionHandler: completion)
  }
  
  /**
   Gets recieved push-notification from `GMSInboxFetchedDate`
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetchPushNotifications(
    forDate date: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void) // swiftlint:disable:this line_length
  {
    
    completion(.Success(getPushNotifications(forDate: date)))
    
  }
  
  /**
   Gets recieved push-notification from `GMSInboxFetchedDate`
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Returns: An array of recieved `GlobalMessageServiceMessage`s
   */
  public class func getPushNotifications(forDate date: NSTimeInterval) -> [GlobalMessageServiceMessage] {
    if let fetchedDate = GMSInboxFetchedDate.getInboxFetchedDate(forDate: date) {
      return synchronized(fetchedDate) { () -> [GlobalMessageServiceMessage] in
        if let messages = fetchedDate.messages?.allObjects as? [GMSInboxMessage] {
          return messages
            .filter { $0.type == GlobalMessageServiceMessageType.PushNotification.rawValue }
            .flatMap { GlobalMessageServiceMessage(message: $0) }
        }
        return []
      }
    }
    return []
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter type: `GlobalMessageServiceMessageType` concrete type of messages which you need to get
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func fetch(
    type: GlobalMessageServiceMessageType,
    date: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void) // swiftlint:disable:this line_length
  {
    
    let errorCompletion: (GlobalMessageServiceError) -> Void = { error in
      completion(.Failure(error))
    }
    
    let gmsToken = GlobalMessageService.registeredGMStoken
    if gmsToken <= 0 {
      errorCompletion(.GMSTokenIsNotSet)
      return
    }
    
    guard let phone = GlobalMessageService.registeredUserPhone else {
      errorCompletion(.MessageFetcherError(.NoPhone))
      return
    }
    
    let urlString: String = "requestMessages/" + type.requestSuffix()
    
    let timeInterval = UInt64(
      floor(
        NSDate(timeIntervalSinceReferenceDate: date).timeIntervalSince1970 * 1000))
    
    let parameters: [String: AnyObject] = [
      "uniqAppDeviceId": NSNumber(unsignedLongLong: gmsToken),
      "phone": NSNumber(longLong: phone),
      "date_utc": NSNumber(unsignedLongLong: timeInterval)
    ]
    
    let requestTime = NSDate().timeIntervalSinceReferenceDate
    
    let completionHandler = messagesFetchHandler(
      type,
      date: date,
      requestTime: requestTime,
      completionHandler: completion)
    
    GMSProvider.sharedInstance.POST(
      .OTTPlatform,
      urlString,
      parameters: parameters,
      checkStatus: false,
      completionHandler: completionHandler
    )
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter type: `GlobalMessageServiceMessageType` concrete type of messages which you need to get
   - Parameter date: `NSTimeInterval` concrete time interval 
   *since 00:00:00 UTC on 1 January 2001* for which you need to get messages
   - Parameter requestTime: `NSTimeInterval` *since 00:00:00 UTC on 1 January 2001* when request was sended
   - Parameter completionHandler: The code to be executed once the request has finished. (optional). 
   This block takes no parameters. 
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   - Returns: Closure that fetches messages and saves it to CodeData DB and executes passed 
   `completionHandler` with result
   */
  private class func messagesFetchHandler(
    type: GlobalMessageServiceMessageType,
    date: NSTimeInterval,
    requestTime: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void)
    -> (Response<[String : AnyObject], GlobalMessageServiceError>) -> Void  // swiftlint:disable:this line_length
  {
    return { response in
      
      guard let fullJSON: [String : AnyObject] = response.value(completion) else {
        return
      }
      
      guard let incomeMessages = fullJSON["messages"] as? [[String: AnyObject]] else {
        completion(.Success([]))
        return
      }
      
      let messages = incomeMessages
        .flatMap() { GlobalMessageServiceMessage(dictionary: $0, andType: type) }
      
      GlobalMessageServiceMessagesFetcher.saveMessages(
        messages,
        date: date,
        requestTime: requestTime,
        completionHandler: completion)
      
    }
  }
  
  /**
   Fetches messages of concrete type from Global Message Services servers
   - Parameter messages: `[GlobalMessageServiceMessage]` an array of recieved messages
   - Parameter date: `NSTimeInterval` concrete date for which you need to get messages
   - Parameter requestTime: `NSTimeInterval` *since 00:00:00 UTC on 1 January 2001* when request was sended
   - Parameter completionHandler: The code to be executed once the request has finished. 
   (optional). This block takes no parameters.
   Returns `Result` `<[GlobalMessageServiceMessage], GlobalMessageServiceError>`, where `result.value` 
   is always contains `Array<GMSMessage>` if there no error occurred, otherwise see `result.error`
   */
  private class func saveMessages(
    messages: [GlobalMessageServiceMessage],
    date: NSTimeInterval,
    requestTime: NSTimeInterval,
    completionHandler completion: (Result<[GlobalMessageServiceMessage], GlobalMessageServiceError>) -> Void) // swiftlint:disable:this line_length
  {
    
    let managedObjectContext = GlobalMessageServiceCoreDataHelper.newManagedObjectContext()
    
    var deletedMessages = [GlobalMessageServiceMessage]()
    messages.forEach() { message in
      
      guard let coreDataMessage = GMSInboxMessage.findObject(
        withPredicate: NSPredicate(format: "messageID == %@", NSDecimalNumber(unsignedLongLong: message.id)),
        inManagedObjectContext: managedObjectContext) as? GMSInboxMessage
        else { return }
      
      coreDataMessage.messageID       = NSDecimalNumber(unsignedLongLong: message.id)
      coreDataMessage.message         = message.message
      coreDataMessage.deliveredDate   = message.deliveredDate.timeIntervalSinceReferenceDate
      coreDataMessage.type            = message.type.rawValue
      
      coreDataMessage.setAlphaNameString(message.alphaName)

      coreDataMessage.setFethcedDate()
      
      if coreDataMessage.deletionMark {
        deletedMessages.append(message)
      }
      
    }
    
    if messages.isEmpty {
      let fetchedDate = GMSInboxFetchedDate.getInboxFetchedDate(
        forDate: date,
        inManagedObjectContext: managedObjectContext,
        createNewIfNotFound: true)
      
      //let date = NSDate(timeIntervalSinceReferenceDate: date)
      if let fetchedDate = fetchedDate {
        if date == NSDate().startOfDay().timeIntervalSinceReferenceDate {
          fetchedDate.lastMessageDate = requestTime
        } else if date > NSDate().endOfDay().timeIntervalSinceReferenceDate {
          fetchedDate.lastMessageDate = NSDate(timeIntervalSinceReferenceDate: date)
            .startOfDay().timeIntervalSinceReferenceDate
        } else {
          fetchedDate.lastMessageDate = NSDate(timeIntervalSinceReferenceDate: date)
            .endOfDay()
            .timeIntervalSinceReferenceDate
        }
      }
      
    }
    
    let result = managedObjectContext.saveSafeRecursively()
    switch result {
    case .Failure(let error):
      completion(.Failure(.MessageFetcherError(.CoreDataSaveError(error as NSError))))
      break
    case .Success:
      completion(.Success(messages.filter({ deletedMessages.indexOf($0) == .None })))
      break
    }
  }
  
}
