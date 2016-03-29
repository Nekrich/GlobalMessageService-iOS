//
//  GlobalMessageService+Localization.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 3/28/16.
//  Copyright © 2016 Global Message Services Worldwide. All rights reserved.
//

import Foundation

public extension GlobalMessageService {
  
  /// `GlobalMessageService.framework` bundle. (read-only)
  public private (set) static var bundle = NSBundle(forClass: GlobalMessageService.self)
  
  /**
   Localizes `GlobalMessageService.bundle`
   
   - parameter language: New language `String`
   */
  static func localize(language: String) {
    
    let localeComponents = NSLocale.componentsFromLocaleIdentifier(language)
    let languageCode = localeComponents[NSLocaleLanguageCode] ?? language
    
    /// list of possible .lproj folders names
    let lprojFolderPatterns: [String?] = [
      language, // en-GB.lproj
      language.stringByReplacingOccurrencesOfString("-", withString: "_"), // en_GB.lproj
      (languageCode != language) ? languageCode : nil, // en.lproj
      NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: language) // English.lproj
    ]
    
    /// Available folders in bundle
    let lprojFoldersPaths: [String] = lprojFolderPatterns.flatMap {
      if let folderName = $0,
        path = GlobalMessageService.bundle.pathForResource(folderName, ofType: "lproj") {
        return path
      } else {
        return nil
      }
    }
    
    let localizedBundlePath = lprojFoldersPaths.first
    
    // Getting localized bundle
    let localizedBudnle: NSBundle
    if let localizedBundlePath = localizedBundlePath,
      let newBundle = NSBundle(path: localizedBundlePath) // swiftlint:disable:this opening_brace
    {
      localizedBudnle = newBundle
      
    // if no localizedBundlePath found, or NSBundle(path: localizedBundlePath) not found, use english language
    } else {
      localize("en")
      return
    }
    
    GlobalMessageService.bundle = localizedBudnle
    
  }
  
}
