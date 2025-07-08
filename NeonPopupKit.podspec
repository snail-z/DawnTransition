
Pod::Spec.new do |s|
  s.name             = 'NeonPopupKit'
  s.version          = '1.1.0'
  s.summary          = 'A flexible chain-style popup manager for iOS.'

  s.description      = <<-DESC
  NeonPopupKit is a lightweight, chain-style popup management framework for iOS.
  It supports custom popup conditions, lifecycle binding, and multiple presentation strategies.
  DESC

  s.homepage         = 'https://github.com/snail-z/PopupKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'snail-z' => 'haozhang0770@163.com' }
  s.source           = { :git => 'https://github.com/snail-z/PopupKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'PopupKit/Classes/**/*'
end
