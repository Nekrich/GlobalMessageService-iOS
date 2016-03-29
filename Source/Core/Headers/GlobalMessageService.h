//
//  GlobalMessageService.h
//  GlobalMessageService
//
//  Created by Vitalii Budnik on 12/11/15.
//
//

#import <Foundation/Foundation.h>

//! Project version number for GlobalMessageService.
FOUNDATION_EXPORT double GlobalMessageServiceVersionNumber;

//! Project version string for GlobalMessageService.
FOUNDATION_EXPORT const unsigned char GlobalMessageServiceVersionString[];

#if defined(__has_include) && __has_include("JSQMessagesViewController/JSQMessagesViewController.h")
  //#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
@import JSQMessagesViewController;
@import JSQSystemSoundPlayer;
#endif
