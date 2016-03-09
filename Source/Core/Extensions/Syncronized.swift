//
//  Syncronized.swift
//  Pods
//
//  Created by Vitalii Budnik on 3/4/16.
//
//

import Foundation

/**
 Runs synchronized `closure` on 'lockObject'
 - Parameter lockObject: The object to be synchronized
 - Parameter closure: The closure to be executed in syncronized mode
 */
internal func synchronized(lockObject: AnyObject, @noescape closure: () -> Void) {
  objc_sync_enter(lockObject)
  closure()
  objc_sync_exit(lockObject)
}

/**
 Returns result of `closure` synchronized with 'lockObject'
 - Parameter lockObject: The object to be synchronized
 - Parameter closure: The closure to be executed in syncronized mode
 - Returns: result of executed closure
 */
internal func synchronized<T>(lockObject: AnyObject, @noescape closure: () -> T) -> T {
  objc_sync_enter(lockObject)
  let result = closure()
  objc_sync_exit(lockObject)
  return result
}
