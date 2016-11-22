#
# Be sure to run `pod lib lint pokitdok-swff.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'pokitdok'
  s.version          = '0.1.0'
  s.summary          = 'A Swift client for the PokitDok API Platform'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://www.pokitdok.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Charlie Thiry' => 'charles.thiry@pokitdok.com' }
  s.source           = { :git => 'https://github.com/pokitdok/pokitdok-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/PokitDok'

  s.ios.deployment_target = '10.1'
  s.source_files = 'pokitdok/*'

end
