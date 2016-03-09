//
//  AlamofireResponse+GMSExtension.swift
//  Pods
//
//  Created by Vitalii Budnik on 1/27/16.
//
//

import Foundation
import Alamofire

// swiftlint:disable missing_docs

internal extension Result {
  
  func value<V>(
    completion: ((Result<V, GlobalMessageServiceError>) -> Void)? = .None)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let resultValue = value else {
      isFailure(completion)
      return .None
    }
    
    return resultValue
    
  }
  
  func isFailure<V>(
    completion: ((Result<V, GlobalMessageServiceError>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    return isFailure(.UnknownError, completion)
    
  }
  
  private func isFailure<V, ET: ErrorType>(
    unknownError: ET,
    _ completionHandler: ((Result<V, ET>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    if isFailure {
      let completion = completionHandlerInMainThread(completionHandler)
      if let resultError = error as? ET {
        completion?(.Failure(resultError))
      } else {
        completion?(.Failure(unknownError))
      }
    }
    return isFailure
  }
  
}

internal extension Response {
  
  func isFailure<V>(
    completion: ((Result<V, GlobalMessageServiceError>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    
    return isFailure(.UnknownError, completion)
    
  }
  
  func value<V>(
    completion: ((Result<V, GlobalMessageServiceError>) -> Void)? = .None)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let resultValue = result.value else {
      isFailure(completion)
      return .None
    }
    
    return resultValue
    
  }
  
  func value<V>(unknownError: Error,
       _ completion: ((Result<V, Error>) -> Void)? = .None)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let value = result.value else {
      isFailure(unknownError, completion)
      return .None
    }
    return value
    
  }
  
}

private extension Response {
  
  private func isFailure<V, CompletionErrorT: ErrorType>(
    error error: (Error) -> CompletionErrorT,
    unknownError: CompletionErrorT,
    completionHandler: ((Result<V, CompletionErrorT>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    if result.isFailure {
      let completion = completionHandlerInMainThread(completionHandler)
      if let resultError = result.error {
        completion?(.Failure(error(resultError)))
      } else {
        completion?(.Failure(unknownError))
      }
    }
    return result.isFailure
  }
  
  private func value<T, CompletionErrorT: ErrorType>(
    error error: (Error) -> CompletionErrorT,
    unknownError: CompletionErrorT,
    completionHandler: ((Result<T, CompletionErrorT>) -> Void)? = .None)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let resultValue = result.value else {
      isFailure(error: error, unknownError: unknownError, completionHandler: completionHandler)
      return .None
    }
    
    return resultValue
    
  }
  
  private func isFailure<V, ET: ErrorType>(
    unknownError: ET,
    _ completionHandler: ((Result<V, ET>) -> Void)? = .None)
    -> Bool // swiftlint:disable:this opening_brace
  {
    if result.isFailure {
      let completion = completionHandlerInMainThread(completionHandler)
      if let resultError = result.error as? ET {
        completion?(.Failure(resultError))
      } else {
        completion?(.Failure(unknownError))
      }
    }
    return result.isFailure
  }
  
  private func value<ET: ErrorType>(
    unknownError unknownError: ET,
    completionHandler: ((Result<Value, ET>) -> Void)? = .None)
    -> Value? // swiftlint:disable:this opening_brace
  {
    
    guard let resultValue = result.value else {
      isFailure(unknownError, completionHandler)
      return .None
    }
    
    return resultValue
    
  }
  
}
