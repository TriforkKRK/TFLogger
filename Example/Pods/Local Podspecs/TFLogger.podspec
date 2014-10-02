#
# Be sure to run `pod lib lint TFLogger.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TFLogger"
  s.version          = "0.0.1"
  s.summary          = "A short description of TFLogger."
  s.description      = <<-DESC
                       An optional longer description of TFLogger

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/TriforkKRK/TFLogger"
  
  s.license          = 'Apache v2'
  s.author           = { "krzysztof" => "kprofic@gmail.com" }
  s.source           = { :git => "https://github.com/TriforkKRK/TFLogger.git", :tag => s.version.to_s }

  s.platform         = :ios, '7.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/**/*.{h,m}'
  s.resources        = 'Pod/Assets/*.png'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  
  # s.frameworks     = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
