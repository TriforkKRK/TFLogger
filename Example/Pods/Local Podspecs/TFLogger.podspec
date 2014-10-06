Pod::Spec.new do |s|
  s.name             = "TFLogger"
  s.version          = "0.0.1"
  s.summary          = "Trifork logging library based on ASL"
  s.description      = ""
  s.homepage         = "https://github.com/TriforkKRK/TFLogger"
  
  s.license          = 'Apache v2'
  s.author           = { "Krzysztof Profic" => "kprofic@gmail.com" }
  s.source           = { :git => "https://github.com/TriforkKRK/TFLogger.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/**/*.{h,m}'
  # s.public_header_files = 'Pod/Classes/**/*.h'
end
