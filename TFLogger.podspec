Pod::Spec.new do |s|
  s.name             = "TFLogger"
  s.version          = "1.0.3"
  s.summary          = "Dependency free logging library."
  s.description      = "Logging library that you can use to have dependency free logs in your other cocoapod libraries. One can implement a custom log handler or use wither a default implementation or CocoaLumberjack handler."
  s.homepage         = "https://github.com/TriforkKRK/TFLogger"
  
  s.license          = 'Apache v2'
  s.author           = { "Krzysztof Profic" => "kprofic@gmail.com" }
  s.source           = { :git => "https://github.com/TriforkKRK/TFLogger.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true

  s.subspec 'Core' do |sub|
    sub.source_files = 'Pod/*.{m,h}'
  end

  s.subspec 'CocoaLumberjackHandler' do |sub|
    sub.source_files = 'Pod/CocoaLumberjackHandler/*.{m,h}'
    sub.dependency 'CocoaLumberjack', '~> 1.9'
    sub.dependency 'TFLogger/Core'
  end

  s.subspec 'NSLogVisualFormat' do |sub|
    sub.source_files = 'Pod/NSLogVisualFormat/*.{m,h}'
    sub.dependency 'TFLogger/Core'
  end

end
