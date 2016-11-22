Pod::Spec.new do |s|
  s.name             = 'pokitdok'
  s.version          = '0.1.0'
  s.summary          = 'A Swift client for the PokitDok API Platform'
  s.homepage         = 'https://www.pokitdok.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Charlie Thiry' => 'charles.thiry@pokitdok.com' }
  s.source           = { :git => 'https://github.com/pokitdok/pokitdok-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/PokitDok'

  s.ios.deployment_target = '10.1'
  s.source_files = 'pokitdok/*'

end
