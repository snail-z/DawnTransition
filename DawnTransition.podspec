
Pod::Spec.new do |s|
  s.name             = 'DawnTransition'
  s.version          = '1.1.0'
  s.summary          = 'A smooth iOS view controller transition framework.'

  s.description      = <<-DESC
    DawnTransition is a simple and easy-to-use iOS transition framework that supports smooth and customizable animations. It solves common gesture conflicts in custom transitions and provides a native-like interactive swipe-back gesture. It has been proven reliable in multiple real-world projects.
                       DESC
  
  s.homepage         = 'https://github.com/snail-z/DawnTransition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'snail-z' => 'haozhang0770@163.com' }
  
  s.swift_versions = ['5.1']
  
  s.ios.deployment_target = '13.0'
  
  s.source           = { :git => 'https://github.com/snail-z/DawnTransition.git', :tag => s.version.to_s }
  s.source_files  = ["Sources/**/*.swift"]
  s.resource_bundles = { 'DawnTransition' => ['Sources/PrivacyInfo.xcprivacy'] }
  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.requires_arc = true
  
end
