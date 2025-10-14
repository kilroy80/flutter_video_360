#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint video_360.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'video_360'
  s.version          = '0.0.1'
  s.summary          = 'video 360 player'
  s.description      = <<-DESC
video 360 player
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = [
    'video_360/Sources/video_360/**/*',
    'video_360/Sources/Swifty360Player/**/*'
  ]
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'video_360_privacy' => ['video_360/Sources/video_360/PrivacyInfo.xcprivacy']}

#   s.dependency 'Swifty360Player', '~> 0.2.7'
#   s.frameworks = 'Swifty360Player'
end