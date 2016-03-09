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
  s.version      = "0.0.1"
  s.summary      = "Meaningfull summary of GlobalMessageService."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  A little bit longer description of GlobalMessageService.
                   DESC

  s.homepage     = "http://www.gms-worldwide.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  # s.license      = "MIT (example)"
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

  s.author             = { "Globale Message Services Worldwide" => "http://www.gms-worldwide.com" }
  # Or just: s.author    = ""
  # s.authors            = { "" => "" }
  # s.social_media_url   = "http://twitter.com/"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  #  When using multiple platforms
  s.ios.deployment_target = "8.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the location from where the source should be retrieved.
  #  Supports git, hg, bzr, svn and HTTP.
  #

  # s.source       = { :git => "http://EXAMPLE/GlobalMessageService.git", :tag => "0.0.1" }
  s.source        = {
        :git => 'https://github.com/Nekrich/GMS_Test.git',
        :tag => s.version.to_s
    }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  #s.source_files = 'Source/Core/**/*.{swift,h}'
 # s.exclude_files = "GlobalMessageService/Pods/**/*.*"
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

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

  # s.ios.dependency "GGLInstanceID", "~> 1.1"
  # s.ios.dependency "GoogleUtilities", "~> 1.1"
  # s.ios.dependency "GoogleSymbolUtilities", "~> 1.0"
  # s.ios.dependency "GoogleNetworkingUtilities", "~> 1.0"
  # s.ios.dependency "GoogleIPhoneUtilities", "~> 1.0"
  # s.ios.dependency "GoogleInterchangeUtilities", "~> 1.1"
  # s.ios.dependency "Google", "~> 1.1"
  #s.ios.dependency "Google/CloudMessaging"#, "~> 1.1.2"

  #s.ios.dependency "XCGLogger", "~> 3.1.1"
  #s.ios.dependency "Alamofire", "~> 3.1.0"

  #s.prepare_command = <<-CMD
  #                      find Pods -regex 'Pods/Google.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)GoogleCloudMessaging\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'
  #                 CMD
  s.xcconfig = {
    #{}"GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) COCOAPODS=1',
    #{}"HEADER_SEARCH_PATHS" => '$(inherited) ${PODS_ROOT}/Google/Headers $(inherited) "${PODS_ROOT}/Headers/Public" "${PODS_ROOT}/Headers/Public/GGLInstanceID" "${PODS_ROOT}/Headers/Public/Google" "${PODS_ROOT}/Headers/Public/GoogleCloudMessaging" "${PODS_ROOT}/Headers/Public/GoogleIPhoneUtilities" "${PODS_ROOT}/Headers/Public/GoogleInterchangeUtilities" "${PODS_ROOT}/Headers/Public/GoogleNetworkingUtilities" "${PODS_ROOT}/Headers/Public/GoogleSymbolUtilities" "${PODS_ROOT}/Headers/Public/GoogleUtilities"',
    #{}"LD_RUNPATH_SEARCH_PATHS" => "$(inherited) '@executable_path/Frameworks' '@loader_path/Frameworks'",
    #{}"LIBRARY_SEARCH_PATHS" => '"${PODS_ROOT}/GGLInstanceID/Libraries" "${PODS_ROOT}/Google/Libraries" "${PODS_ROOT}/GoogleCloudMessaging/Libraries" "${PODS_ROOT}/GoogleIPhoneUtilities/Libraries" "${PODS_ROOT}/GoogleInterchangeUtilities/Libraries" "${PODS_ROOT}/GoogleNetworkingUtilities/Libraries" "${PODS_ROOT}/GoogleSymbolUtilities/Libraries" "${PODS_ROOT}/GoogleUtilities/Libraries"',
    #{}"OTHER_CFLAGS" => '$(inherited)  -isystem "${PODS_ROOT}/Headers/Public" -isystem "${PODS_ROOT}/Headers/Public/GGLInstanceID" -isystem "${PODS_ROOT}/Headers/Public/Google" -isystem "${PODS_ROOT}/Headers/Public/GoogleCloudMessaging" -isystem "${PODS_ROOT}/Headers/Public/GoogleIPhoneUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleInterchangeUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleNetworkingUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleSymbolUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleUtilities"',
    #{}"OTHER_LDFLAGS" => '-ObjC -l"GGLCloudMessaging" -l"GGLCore" -l"GGLInstanceIDLib" -l"GIP_Locale" -l"GIP_Reachability" -l"GSDK_Overload" -l"GTMSessionFetcher_core" -l"GTMSessionFetcher_full" -l"GTMStackTrace" -l"GTM_AddressBook" -l"GTM_DebugUtils" -l"GTM_GTMURLBuilder" -l"GTM_KVO" -l"GTM_NSData+zlib" -l"GTM_NSDictionary+URLArguments" -l"GTM_NSScannerJSON" -l"GTM_NSStringHTML" -l"GTM_NSStringXML" -l"GTM_Regex" -l"GTM_RoundedRectPath" -l"GTM_StringEncoding" -l"GTM_SystemVersion" -l"GTM_UIFont+LineHeight" -l"GTM_core" -l"GTM_iPhone" -l"GcmLib" -l"ProtocolBuffers" -l"sqlite3" -l"stdc++" -l"z" -framework "AddressBook" -framework "AssetsLibrary" -framework "CoreFoundation" -framework "CoreGraphics" -framework "CoreLocation" -framework "CoreMotion" -framework "MessageUI" -framework "SystemConfiguration" -force_load $(PODS_ROOT)/GoogleUtilities/Libraries/libGTM_NSData+zlib.a',

    #"OTHER_CFLAGS" => '$(inherited)  -isystem "${PODS_ROOT}/Headers/Public" -isystem "${PODS_ROOT}/Headers/Public/GGLInstanceID" -isystem "${PODS_ROOT}/Headers/Public/Google" -isystem "${PODS_ROOT}/Headers/Public/GoogleCloudMessaging" -isystem "${PODS_ROOT}/Headers/Public/GoogleIPhoneUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleInterchangeUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleNetworkingUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleSymbolUtilities" -isystem "${PODS_ROOT}/Headers/Public/GoogleUtilities"',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    "OTHER_LDFLAGS" => '-ObjC'
    #'ENABLE_BITCODE'         => 'NO'
  }
        #"HEADER_SEARCH_PATHS": "\"${PODS_ROOT}/Headers/Public/GoogleCloudMessaging\""

  s.pod_target_xcconfig = {
		#'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/Google/Libraries',
    'OTHER_LDFLAGS'          => '$(inherited) -ObjC',
    'ENABLE_BITCODE'         => 'NO',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
	}


	s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
		#core.name = "GlobalMessageService"
    core.resources = 'Resources/Core/*.*'
		core.source_files = 'Source/Core/**/*.{swift,h}'
    #core.
		#core.exclude_files = "Source/InboxViewController"
    core.dependency 'XCGLogger', '~> 3.1.1'
    core.dependency 'Alamofire', '~> 3.1.0'
		core.dependency 'Google/CloudMessaging'

    core.public_header_files = 'Source/Core/Headers/*.h'
		#core.framework  = "GlobalMessageService"
    #core.dependency 'GlobalMessageService/Google'
		#core.dependency 'GlobalMessageService/InboxViewController'

		core.frameworks = "Foundation", "CoreData", "UIKit", "MapKit"
		#core.preserve_path = "Source"
		#core.module_name = 'GlobalMessageService.Core'
		#s.vendored_frameworks = "GlobalMessageService"
  end

  #s.subspec 'Google' do |sucks|
  #  sucks.dependency 'Google/CloudMessaging'
		#sucks.module_name = 'GlobalMessageService.GoogleSucks'
  #end

	s.subspec 'InboxViewController' do |inboxvc|
		#inboxvc.name = "GlobalMessageServiceInboxViewController"
		inboxvc.source_files = 'Source/InboxViewController/**/*.{swift,h}'
		#inboxvc.resources = "Source/InboxViewController/*.{xib}"

		inboxvc.dependency 'GlobalMessageService/Core'

		inboxvc.dependency 'JSQMessagesViewController', '~> 7.2.0'
		inboxvc.dependency 'DZNEmptyDataSet', '~> 1.7.3'

		#inboxvc.framework  = "GlobalMessageServiceInboxViewController"
		#inboxvc.frameworks = "Foundation", "Chatto", "ChattoAdditions"
		#inboxvc.preserve_path = "Source/Core"
		#inboxvc.module_name = 'GlobalMessageService.InboxViewController'
		#s.vendored_frameworks = "GlobalMessageServiceInboxViewController"
  end

end
