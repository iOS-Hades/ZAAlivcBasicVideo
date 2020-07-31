#
# Be sure to run `pod lib lint AlivcBasicVideo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AlivcBasicVideo'
  s.version          = '0.1.0'
  s.summary          = '阿里播放器的基础UI'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
阿里播放器的基础UI
                       DESC

  s.homepage         = 'https://github.com/iOS-Hades/AlivcBasicVideo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iOS-Hades' => '2319587028@qq.com' }
  s.source           = { :git => 'https://github.com/iOS-Hades/AlivcBasicVideo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.static_framework = true

  s.source_files =  'AlivcBasicVideo/Classes/**/*.{h,m,mm}'
    
  s.prefix_header_contents = '#import "AlivcMacro.h"','#import "AlivcImage.h"'

  s.resource_bundles = {
      'AlivcBasicVideo' => ['AlivcBasicVideo/Assets/AlivcImage_LongVideo/*.png','AlivcBasicVideo/Assets/AlivcImage_Player/*.png','AlivcBasicVideo/Assets/AlivcImage_TimeShift/*.png','AlivcBasicVideo/Assets/*.dat','AlivcBasicVideo/Classes/**/*.xib']
  }
  
  s.dependency 'AlivcCommon'
  s.dependency 'MJRefresh', '~> 3.1.15.7'
  s.dependency 'MRDLNA'

   s.dependency 'AliPlayerSDK_iOS', '5.1.4'
   s.dependency 'AliPlayerSDK_iOS_ARTP', '5.1.4'
   s.dependency 'AliPlayerSDK_iOS_ARTC', '5.1.4'


end
