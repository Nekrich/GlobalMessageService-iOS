//
//  GlobalMessageServicesSubscriber.swift
//  GlobalMessageServices
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Message Services Worldwide. All rights reserved.
//

import Foundation

/**
 Stores subscriber's e-mail & phone
 */
internal struct GlobalMessageServicesSubscriber {
	
  /// Subscriber's e-mail
	var email: String?
  
  /// Subscriber's phone number
	var phone: Int64?
  
  /// Subscriber's registration date
  var registrationDate: NSDate?
	
  // swiftlint:disable valid_docs
  /**
   Initializes new subscriber with passed e-mail and phone
   - parameter email: `String` containig subscriber's e-mail
   - parameter phone: `Int64` containig subscriber's phone
   - returns: initialized instance
   */
  init(withEmail email: String?, phone: Int64?, registrationDate: NSDate? = .None) {
    // swiftlint:enable valid_docs
		self.email = email
		self.phone = phone
    self.registrationDate = registrationDate
	}
	
  // swiftlint:disable valid_docs
  /**
   Initializes new subscriber with passed dictionary
   - parameter dictionary: `[String: AnyObject]` containig subscriber's information 
   `["email": "SomeEmail", "phone": 380XXXXXXXXX]`. Can be `nil`
   - returns: initialized instance, or `nil`, if no dictionary passed
   */
	init?(withDictionary dictionary: [String: AnyObject]?) {
    // swiftlint:enable valid_docs
		if let dictionary = dictionary {
			//guard let email = dictionary["email"] as? String,
			//	phone = dictionary["phone"] as? String else { return nil }
			email = dictionary["email"] as? String
      
      let phone: Int64?
      if let _phone = Int64(dictionary["phone"] as? String ?? "0") {
        phone = _phone != 0 ? _phone : .None
      } else {
        phone = .None
      }
      
			self.phone = phone
      
      if let registrationDate = dictionary["registrationDate"] as? NSNumber {
        self.registrationDate = NSDate(timeIntervalSinceReferenceDate: registrationDate.doubleValue)
      } else if let registrationDate = dictionary["registrationDate"] as? Double {
        self.registrationDate = NSDate(timeIntervalSinceReferenceDate: registrationDate)
      } else {
        self.registrationDate = .None
      }
      
		} else {
			return nil
		}
	}
	
}

// MARK: DictionaryConvertible
internal extension GlobalMessageServicesSubscriber {
	
  /**
   Converts current subscriber `struct` to dictionary `[String : AnyObject]` with subscribers e-mail and phone
   - returns: `[String : AnyObject]` dictionary with subscribers e-mail and phone
   */
	func asDictionary() -> [String : AnyObject] {
		var result = [String: AnyObject]()
		if let email = email {
			result["email"] = email
		}
		if let phone = phone {
			result["phone"] = "\(phone)"
		}
    if let registrationDate = registrationDate {
      result["registrationDate"] = NSNumber(double: registrationDate.timeIntervalSinceReferenceDate)
    }
		return result
	}
	
}

// MARK: CutomStringConvertible
extension GlobalMessageServicesSubscriber: Equatable {}

/**
 Compares two instances of `GlobalMessageServicesSubscriber`
 - Parameter lhs: first `GlobalMessageServicesSubscriber` instance to compare
 - Parameter rhs: second `GlobalMessageServicesSubscriber` instance to compare
 - Returns: `true` if subscribers have equal phone numbers and e-mails, `false` otherwise
 */
internal func == (lhs: GlobalMessageServicesSubscriber, rhs: GlobalMessageServicesSubscriber) -> Bool {
	return lhs.email == rhs.email && lhs.phone == rhs.phone && lhs.registrationDate == rhs.registrationDate
}
