//
//  GMSProviderMobilePlatformJSONResponseSerializers.swift
//
// Copyright (c) 2015–2016 Global Message Services (http://gms-worlwide.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire

/**
 Custom JSON response serializers
 */
internal struct GlobalMessageServiceJSONResponseSerializers { // swiftlint:disable:this type_name
  
  /**
   Creates a response serializer that returns a JSON object constructed from the response data using
   `NSJSONSerialization` with the specified reading options.
   
   - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
   
   - returns: A JSON object response serializer.
   */
  static func JSONResponseSerializer(
    options options: NSJSONReadingOptions = .AllowFragments)
    -> ResponseSerializer<[String : AnyObject], GlobalMessageServiceError> // swiftlint:disable:this line_length
  {
    return ResponseSerializer { request, response, data, error in
      
      let result = Request.JSONResponseSerializer(options: options)
        .serializeResponse(request, response, data, error)
      
      guard let value = result.value else {
        if let error = result.error {
          return .Failure(.RequestError(.Error(error)))
        } else {
          return .Failure(.RequestError(.UnknownError))
        }
      }
      
      guard let json = value as? [String : AnyObject] else {
        return .Failure(.ResultParsingError(.CantRepresentResultAsDictionary))
      }
      
      return .Success(json)
      
    }
  }
  
  /**
   Creates a response serializer that returns a JSON object constructed from the response data using
   `NSJSONSerialization` with the specified reading options.
   Additionally checks `"status"` flag
   
   - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
   
   - returns: A JSON object response serializer.
   */
  static func JSONResponseSerializer_checkStatusFlag(
    options options: NSJSONReadingOptions = .AllowFragments)
    -> ResponseSerializer<[String : AnyObject], GlobalMessageServiceError>  // swiftlint:disable:this line_length
  {
    return ResponseSerializer { request, response, data, error in
      
      let result = JSONResponseSerializer(options: options).serializeResponse(request, response, data, error)
      
      guard let json = result.value else {
        if let error = result.error {
          return .Failure(error)
        } else {
          return .Failure(.ResultParsingError(.UnknownError))
        }
      }
      
      guard let status = json["status"] as? Bool else {
        return .Failure(.ResultParsingError(.NoStatus))
      }
      
      if !status {
        return .Failure(.ResultParsingError(.StatusIsFalse(json["response"] as? String)))
      }
      
      return .Success(json)
      
    }
  }
}
