//
//  GMSLog.swift
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 12/10/15.
//  Copyright © 2015 Global Messages Services Worldwide. All rights reserved.
//

import Foundation
import UIKit
import XCGLogger

/// `XCGLogger` instance for `GlobalMessageService.framework`
internal let gmsLog = GlobalMessageService.gmsLog

internal extension GlobalMessageService {
	/**
   `XCGLogger` instance for `GlobalMessageService.framework`
   */
	static let gmsLog: XCGLogger = {
		
		let url = NSFileManager.cachesDirectoryURL!.URLByAppendingPathComponent("gmslog.txt")
		
    let log = XCGLogger(identifier: "GMSslog")
    
		log.setup(
      .Verbose,
      showLogIdentifier: true,
      showFunctionName: true,
      showThreadName: true,
      showLogLevel: true,
      showFileNames: true,
      showLineNumbers: true,
      showDate: true,
      writeToFile: url,
      fileLogLevel: .Verbose)
		
    log.xcodeColorsEnabled = true
		
    log.xcodeColors = [
			.Verbose: .lightGrey,
			.Debug: .darkGrey,
			.Info: .darkGreen,
      .Warning: XCGLogger.XcodeColor(fg: UIColor.orangeColor()),
			.Error: XCGLogger.XcodeColor(fg: UIColor.redColor()),
      .Severe: XCGLogger.XcodeColor(fg: UIColor.whiteColor(), bg: UIColor.redColor())
		]
    
		return log
    
	}()
	
}
