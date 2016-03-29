#
#  Be sure to run `pod spec lint GlobalMessageService.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

	s.name         = "GlobalMessageService"
  s.version      = "0.0.3"
  s.summary      = "Global Message Services APNs reciever"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
    Recieves APNs, fetches and stores SMS and Viber messages,
		that have been delivered to customer’s subscriber
  DESC

  s.homepage     = "http://www.gms-worldwide.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = {
		"Globale Message Services Worldwide" => "http://www.gms-worldwide.com"
	}
  # Or just: s.author    = ""
  # s.authors            = { "" => "" }
  # s.social_media_url   = "http://twitter.com/"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.ios.deployment_target = "8.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  s.source = {
    :git => 'https://github.com/GlobalMessageServicesAG/GlobalMessageService-iOS.git',
    :tag => s.version.to_s
  }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.exclude_files = 'Build/**/*.*", "Pods/**/*.*", "GlobalMessageServiceTests/**/*.*'

  #s.public_header_files = "Source/Headers/*.h"
  #s.private_header_files = "GlobalMessageService/Private.h"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  #s.resources = "Resources/*.*"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  #s.framework  = "GlobalMessageService"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  #s.ios.vendored_frameworks = "GlobalMessageService"
  # s.library   = "iconv"
  # s.libraries = "Libraries/libGGLInstanceIDLib.a", "Libraries/libGGLCore.a", "Libraries/libGcmLib.a", "Libraries/libProtocolBuffers.a", "Libraries/libGIP_Reachability.a", "Libraries/libGTMSessionFetcher_core.a", "Libraries/libGTMSessionFetcher_full.a", "Libraries/libGSDK_Overload.a", "Libraries/libGTM_AddressBook.a"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = {
  #   'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
  #   "OTHER_LDFLAGS" => '-ObjC'
  # }

  s.pod_target_xcconfig = {
    #'OTHER_LDFLAGS'          => '$(inherited) -ObjC',
    'ENABLE_BITCODE'         => 'NO'
    # 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
	}

	s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
    core.resources = 'Resources/Core/*.*'
		core.source_files = 'Source/Core/**/*.{swift,h}'
    core.dependency 'XCGLogger', '~> 3.3'
		core.dependency 'Google/CloudMessaging'

    core.public_header_files = 'Source/Core/Headers/*.h'

		core.frameworks = "Foundation", "CoreData", "UIKit", "CoreLocation"
  end

	s.subspec 'Inbox' do |inboxvc|
		inboxvc.source_files = 'Source/InboxViewController/**/*.{swift}'

		inboxvc.dependency 'GlobalMessageService/Core'
	
		inboxvc.dependency 'JSQMessagesViewController', '~> 7.2.0'
		inboxvc.dependency 'DZNEmptyDataSet', '~> 1.7.3'

  end

end
