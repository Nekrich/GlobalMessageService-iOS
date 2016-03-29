//
//  GMSProvider+POST.swift
//  Pods
//
//  Created by Vitalii Budnik on 12/15/15.
//
//

import Foundation
import XCGLogger

internal extension GMSProvider {
  /**
   List of available REST API providers
   */
  internal enum RESTProvider {
    /// Moblie platform
    case MobilePlatform
    /// OTTBulk platform
    case OTTPlatform
    
    /**
     Returns an `NSURL` for concrete provider type
     - Returns: An `NSURL` for concrete provider type
     */
    func URL() -> NSURL {
      switch self {
      case .MobilePlatform:
        return GMSProvider.mobilePlatformURL
      case .OTTPlatform:
        return GMSProvider.ottBulkPlatformURL
      }
    }
    
  }
  
  /**
   POSTs request to MobilePlatform to specifyed API URL string with parameters
   - Parameter urlString: The URL string relative to MobilePlatform URL
   - Parameter parameters: The parameters
   - Returns: The created `Request`
   */
  internal func POST(
    urlString: String,
    parameters: [String : AnyObject])
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(.MobilePlatform, urlString, parameters: parameters)
    
  }
  
  /**
   POSTs request to specifyed relative URL string of REST API provider with parameters
   - Parameter restProvider: The REST API provider
   - Parameter urlString: The URL string relative to REST API provider URL
   - Parameter parameters: The parameters
   - Returns: The created `Request`
   */
  internal func POST(
    restProvider: RESTProvider,
    urlString: String,
    parameters: [String : AnyObject])
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(NSURL(string: urlString, relativeToURL: restProvider.URL())!, parameters: parameters)
    
  }
  
  

  /**
   POSTs request to specifyed relative URL string of MobilePlatform REST API with parameters
   
   - Parameter urlString: The URL string relative to MobilePlatform URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. 
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   */
  internal func POST(
    urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (GlobalMessageServiceResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(
      .MobilePlatform,
      urlString,
      parameters: parameters,
      checkStatus: checkStatus,
      completionHandler: completion)
    
  }
  

  /**
   POSTs request to specifyed relative URL string of REST API provider with parameters
   
   - Parameter restProvider: The REST API provider
   - Parameter urlString: The URL string relative to REST API provider URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. 
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   
   */
  internal func POST(
    restProvider: RESTProvider,
    _ urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (GlobalMessageServiceResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
    
    return POST(
      NSURL(string: urlString, relativeToURL: restProvider.URL())!,
      parameters: parameters,
      checkStatus: checkStatus,
      completionHandler: completion)
    
  }
  // swiftlint:enable line_length
  
  /**
   POSTs request to specifyed relative URL with parameters
   
   - Parameter url: The URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. 
   Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   
   - Returns: The created `Request`
   */
  private func POST(
    url: NSURL,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (GlobalMessageServiceResult<[String : AnyObject]> -> Void)? = .None)
    -> NSURLSessionTask? // swiftlint:disable:this opening_brace
  {
        
    guard let request = self.request(url, parameters: parameters).value(completion) else {
      return .None
    }
    
    let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
      
      guard let json = self.JSONdataTaskResult(data, response, error, checkStatus: checkStatus)
        .value(completion) else {
        return
      }
      
      completion?(.Success(json))
      
    }
    
    dataTask.resume()
    
    return dataTask
    
  }
  
  /**
   Serializes result of `NSURLSession.dataTaskWithRequest`
   
   - parameter data:        The data returned by the server.
   - parameter response:    A `NSHTTPURLResponse` that provides response metadata, such as 
   HTTP headers and status code.
   - parameter error:       An error object that indicates why the request failed, 
   or nil if the request was successful.
   - parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. 
   Default: `true`
   
   - returns: `GlobalMessageServiceResult` containing serialized JSON (`[String : AnyObject]]`)
   */
  private func JSONdataTaskResult(
    data: NSData?,
    _ response: NSURLResponse?,
    _ error: NSError?,
    checkStatus: Bool = true)
    -> GlobalMessageServiceResult<[String : AnyObject]> // swiftlint:disable:this opening_brace
  {
    
    guard let data = data else {
      if let error = error {
        return .Failure(.RequestError(.Error(error)))
      } else {
        return .Failure(.RequestError(.UnknownError))
      }
    }
    
    let json: [String: AnyObject]
    do {
      let dataObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
      guard let serializedDataObject = dataObject as? [String: AnyObject] else {
        return .Failure(.ResultParsingError(.CantRepresentResultAsDictionary))
      }
      json = serializedDataObject
    } catch {
      return .Failure(.ResultParsingError(.JSONSerializationError(error as NSError)))
    }
    
    if checkStatus {
      
      guard let status = json["status"] as? Bool else {
        return .Failure(.ResultParsingError(.NoStatus))
      }
      
      if !status {
        return .Failure(.ResultParsingError(.StatusIsFalse(json["response"] as? String)))
      }
      
    }
    
    return .Success(json)
    
  }
  
  /**
   Creates `NSURLRequest`
   
   - parameter URL:        The URL
   - parameter parameters: The parameters for `NSURLRequest`
   
   - returns: `GlobalMessageServiceResult<NSURLRequest>`
   */
  private func request(URL: NSURL,
    parameters: [String : AnyObject]?)
    -> GlobalMessageServiceResult<NSURLRequest> // swift:lint:disable:this opening_brace
  {
    let request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "POST"
    
    guard let parameters = parameters else {
      return .Success(request)
    }
    
    do {
      let jsonData = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
      request.HTTPBody = jsonData
      
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
    } catch {
      gmsLog.error("\(error as NSError)")
      
      return .Failure(.RequestError(.ParametersSerializationError(error as NSError)))
    }
    
    return .Success(request)
  }
  
}
