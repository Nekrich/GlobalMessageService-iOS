//
//  GMSProvider+POST.swift
//  Pods
//
//  Created by Vitalii Budnik on 12/15/15.
//
//

import Foundation
import Alamofire
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
    -> Request // swiftlint:disable:this opening_brace
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
    -> Request // swiftlint:disable:this opening_brace
  {
    
    return manager.request(
      .POST,
      NSURL(string: urlString, relativeToURL: restProvider.URL())!,
      parameters: parameters,
      encoding: ParameterEncoding.JSON)
    
  }
  
  // swiftlint:disable line_length

  /**
   POSTs request to specifyed relative URL string of MobilePlatform REST API with parameters
   - Parameter urlString: The URL string relative to MobilePlatform URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   - Returns: The created `Request`
   */
  internal func POST(
    urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (Response<[String : AnyObject], GlobalMessageServiceError> -> Void)? = .None)
    -> Request // swiftlint:disable:this opening_brace
  {
    // swiftlint:enable line_length
    
    return POST(
      .MobilePlatform,
      urlString,
      parameters: parameters,
      checkStatus: checkStatus,
      completionHandler: completion)
    
  }
  
  // swiftlint:disable line_length
  /**
   POSTs request to specifyed relative URL string of REST API provider with parameters
   - Parameter restProvider: The REST API provider
   - Parameter urlString: The URL string relative to REST API provider URL
   - Parameter parameters: The parameters
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   - Returns: The created `Request`
   */
  internal func POST(
    restProvider: RESTProvider,
    _ urlString: String,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (Response<[String : AnyObject], GlobalMessageServiceError> -> Void)? = .None)
    -> Request // swiftlint:disable:this opening_brace
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
   - Parameter checkStatus: `Bool` that indicates to check `"status"` flag in JSON response. Default: `true`
   - Parameter completionHandler: The code to be executed once the request has finished.
   - Returns: The created `Request`
   */
  private func POST(
    url: NSURL,
    parameters: [String : AnyObject]?,
    checkStatus: Bool = true,
    completionHandler completion: (Response<[String : AnyObject], GlobalMessageServiceError> -> Void)?)
    -> Request // swiftlint:disable:this opening_brace
  {
    
    let request = manager.request(
      .POST,
      url,
      parameters: parameters,
      encoding: ParameterEncoding.JSON)//,
      //headers: GMSProvider.defaultHTTPAdditionalHeaders)
      .validate()
    
    gmsLog.verbose("\nrequest:\n\(request.debugDescription)\n")
    
    let postCompletionHandler: Response<[String : AnyObject], GlobalMessageServiceError> -> Void
    postCompletionHandler = { response in
      
      gmsLog.verbose("\nANSWER request:\n\(request.debugDescription)\nresponse:\n\(response)")
      
      let errorCompletion: (GlobalMessageServiceError) -> Void = { error in
        let response = Response(
          request: response.request,
          response: response.response,
          data: response.data,
          result: Result<[String : AnyObject], GlobalMessageServiceError>.Failure(error)
        )
        
        completion?(response)
      }
      
      guard let _ = response.result.value else { errorCompletion(response.result.error!); return }
      
      completion?(response)
      
    }
    
    let serializer: ResponseSerializer<[String : AnyObject], GlobalMessageServiceError>
    
    if checkStatus {
      serializer = GlobalMessageServiceJSONResponseSerializers.JSONResponseSerializer_checkStatusFlag()
    } else {
      serializer =  GlobalMessageServiceJSONResponseSerializers.JSONResponseSerializer()
    }
    
    return request.response(
      queue: queue,
      responseSerializer: serializer,
      completionHandler: postCompletionHandler)
    
  }
  
  /**
   POSTs request to specifyed relative URL with parameters
   - Parameter url: The URL
   - Parameter parameters: The parameters
   - Returns: The created `Request`
   */
  private func POST(
    url: NSURL,
    parameters: [String : AnyObject]?)
    -> Request // swiftlint:disable:this opening_brace
  {
    return manager.request(
      .POST,
      url,
      parameters: parameters,
      encoding: ParameterEncoding.JSON)
  }
  
}
