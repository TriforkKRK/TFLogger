# TFLogger

[![CI Status](http://img.shields.io/travis/krzysztof/TFLogger.svg?style=flat)](https://travis-ci.org/krzysztof/TFLogger)
[![Version](https://img.shields.io/cocoapods/v/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)
[![License](https://img.shields.io/cocoapods/l/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)
[![Platform](https://img.shields.io/cocoapods/p/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)

TFLogger
========

Trifork logging library based on ASL

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Integration with other projects

TFLogger may be integrated with other projects using NSLog visual format:
#TODO visual format description.

In order to have On Demand integration with TFLogger. Do the following:
1) Use NSLog with log visual formatting in all your implementation files across the library you develop.
2) Include the following in Podspec:

?? dependency ??
s.prefix_header_contents = '#if NSLOG_TO_TFLOGGER_ENABLED', '#import <TFLogger/TFLogger.h>',  '#define NSLog(...) NSLogToTFLoggerAdapter(__VA_ARGS__)', '#endif'

3) That's it. Now clients of your library are able to optionally turn on TFLogger integration, have your logs delivered with appropriate log levels and decide what to do with them.

In order to take advantage of a library that has TFLogger integration as an option do the following:

1) In your projects Podfile add a dependency to TFLogger and to a pod you want to use:

target 'MyProject', :exclusive => true do
pod "TFLogger"
pod 'TFUtils'
end

2) Add a pod post_install step to activate visual format NSLog->TFLogger channel.

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'NSLOG_TO_TFLOGGER_ENABLED=1'
        end
    end
end



## Requirements

## Installation

TFLogger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TFLogger"

## Author

Krzysztof Profic, kprofic@gmail.com

## License

TFLogger is available under the Apache v2. See the LICENSE file for more info.

