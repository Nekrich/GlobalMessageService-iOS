[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://swift.org/)
[![Build Status](https://travis-ci.org/GlobalMessageServicesAG/GlobalMessageService-iOS.svg?branch=master)](https://travis-ci.org/GlobalMessageServicesAG/GlobalMessageService-iOS)

### Installation

#### CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate GlobalMessageService into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  def installer.verify_no_static_framework_transitive_dependencies; end
end

pod 'GlobalMessageService', :git => 'https://github.com/GlobalMessageServicesAG/GlobalMessageService-iOS.git', :tag => '0.0.4'
```

Then, run the following command:

```bash
$ pod install
```

#### Add files
Add [```GMSGoogleCloudMessagingDelegate.swift```](https://github.com/GlobalMessageServicesAG/GlobalMessageService-iOS/tree/master/targetFiles/GMSGoogleCloudMessagingDelegate.swift) file to your project

#### Configure target
Disable bitcode (set `ENABLE_BITCODE` to `false`) in build settings for your target. See Google Cloud Messaging [issue](https://github.com/google/gcm/issues/91)

#### Modify AppDelegate
##### Add ```import``` statement
```swift
import GlobalMessageService
```

In  `func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool` add following
```swift
  GlobalMessageService.register(
    applicationKey: "Your Global Message Service Key",
    googleCloudMessagingHelper: GMSGoogleCloudMessagingDelegate.sharedInstance,
    andGoogleCloudMessagingSenderID: "Your Google Cloud Messaging Sender ID")
```

In  `func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)` add following
```swift
  GlobalMessageService.applicationDidRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
```

In `func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)` add following
```swift
  GlobalMessageService.applicationDidReceiveRemoteNotification(userInfo)

  completionHandler(.NewData)
```

#### Register your application for Remote Notification

##### Certificates
Configure push-notifications in [Certificates, Identifiers & Profiles](https://developer.apple.com/account/ios/certificate/certificateList.action) section of Apple Developer Member Center ([manual](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6))
##### Registering for Remote Notifications
Register your application to receive remote push-notifications ([manual](https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW2))

### Usage
To start using GlobalMessageService framework you should provide correct subscriber e-mail & phone (optionally)

#### Subscriber information
##### Add
To add new subscriber you should call
```swift
GlobalMessageService.addSubscriber(
  email: String,
  phone: Int64?,
  completionHandler: ((GlobalMessageServiceResult<UInt>) -> Void)? = .None)
```
In completion handler result you will get GlobalMessageService subscriber ID if success

##### Edit
To edit subscriber information you should call
```swift
GlobalMessageService.updateSubscriberInfo(
  email: String,
  phone: Int64?,
  completionHandler: ((GlobalMessageServiceResult<Void>) -> Void)? = .None)
```
In completion handler result you will get success `Bool` flag

Update subscriber's location
```swift
GlobalMessageService.updateSubscriberLocation(
  location: CLLocation?,
  completionHandler: ((GlobalMessageServiceResult<Void>) -> Void)? = .None)
```

Update subscriber's changed Google cloud messages token
```swift
GlobalMessageService.updateGCMToken(
  token: String?,
  completionHandler: ((GlobalMessageServiceResult<Void>) -> Void)? = .None)
```

Update subscriber can receive push-notifications flag
```swift
GlobalMessageService.allowRecievePush(
  allowPush: Bool,
  completionHandler: ((GlobalMessageServiceResult<Void>) -> Void)? = .None)
```

#### Get delivered messages
To fetch delivered messages call
```swift
GlobalMessageService.fetchMessages(
  forDate: NSDate,
  completionHandler: ((GlobalMessageServiceResult<[GlobalMessageServiceMessage]>) -> Void)? = .None)
```
Example
```swift
let someDate = NSDate()
GlobalMessageService.fetchMessages(forDate: someDate) { result in
  guard let messages = result.value else { return }
  // you code goes here
}
```

### How to get keys, push-notifications, IDs

#### GlobalMessageService application key
Contact [Global Message Services](http://www.gms-worldwide.com/en/kontakty.html)

#### Google Cloud Messaging (push-notifications)
[Enable Google Cloud Messaging API](https://console.developers.google.com/apis/api/googlecloudmessaging/) for you project

[Enable Google services](https://developers.google.com/mobile/add?platform=ios) for your app

#### Google Cloud Messaging Sender ID
Google Cloud Messaging Sender ID is your Project number that you can get in [Google Developer Console](https://console.developers.google.com/)

### License
[MIT][LICENSE]
[LICENSE]: LICENSE

#### 3rdparties
[XCGLogger](https://github.com/DaveWoodCom/XCGLogger) by [Dave Wood](https://twitter.com/DaveWoodX). [MIT license](https://github.com/DaveWoodCom/XCGLogger/blob/master/LICENSE.txt)

[Google Cloud Messaging](https://github.com/google/gcm/blob/master/LICENSE)
