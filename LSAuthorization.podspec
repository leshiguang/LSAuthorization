#
# Be sure to run `pod lib lint LSAuthorization.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LSAuthorization'
  s.version          = '0.2.0'
  s.summary          = 'A short description of LSAuthorization.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/leshiguang/LSAuthorization'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'alex.wu' => 'alex.wu@dianping.com' }
  s.source           = { :git => 'https://github.com/leshiguang/LSAuthorization.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LSAuthorization/Classes/Public/*'
  
#  s.static_framework =true
  s.resource_bundles = {
     'LSAuthorization' => ['LSAuthorization/Assets/*']
  }
  s.vendored_framework  = 'LSAuthorizationFramework-0.1.9/ios/LSAuthorizationFramework.framework'
  s.public_header_files = 'LSAuthorization/Classes/Public/LSAuthorization.h'
#  s.dependency 'LSNetworkingModule'
  s.dependency 'LSNetwork_iOS'
end
# pod repo push lifesense-github LSAuthorization.podspec --allow-warnings --verbose
# pod package LSAuthorization.podspec --force --no-mangle --spec-sources=https://gitlab.lifesense.com/commonlib_ios/CocoaPodsSpecs.git,https://github.com/CocoaPods/Specs
