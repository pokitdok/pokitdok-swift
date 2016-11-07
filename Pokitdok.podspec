Pod::Spec.new do |s|
  s.name = 'Pokitdok'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Pokitdok Request Library'
  s.homepage = 'https://pokitdok.com/'
  s.source = { :git => 'https://github.com/pokitdok/pokitdok-swift.git' }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'pokitdok/*.swift'
end
