#
# Be sure to run `pod lib lint IPaImageURLLoader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IPaImageURLLoader'
  s.version          = '2.3'
  s.summary          = 'Easy loading Image with url management,can cache Image, and support photo kit'
  s.swift_version    = '4.2'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Include IPaImageURLButton , IPaImageURLView, set the URL to download image and cache automatically'

  s.homepage         = 'https://github.com/ipapamagic/IPaImageURLLoader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'IPa Chen' => 'ipapamagic@gmail.com' }
  s.source           = { :git => 'https://github.com/ipapamagic/IPaImageURLLoader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'IPaImageURLLoader/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IPaImageURLLoader' => ['IPaImageURLLoader/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'IPaSecurity', '~> 3.0'
  s.dependency 'IPaDesignableUI', '~> 3.1'

end
