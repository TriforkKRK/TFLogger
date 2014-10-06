# TFLogger

[![CI Status](http://img.shields.io/travis/krzysztof/TFLogger.svg?style=flat)](https://travis-ci.org/krzysztof/TFLogger)
[![Version](https://img.shields.io/cocoapods/v/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)
[![License](https://img.shields.io/cocoapods/l/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)
[![Platform](https://img.shields.io/cocoapods/p/TFLogger.svg?style=flat)](http://cocoadocs.org/docsets/TFLogger)


Trifork logging library based on ASL. With this lib you can do the following:
1. Use it as your logging facility (`TFLogDebug`, `TFLogError`, ... )
2. Forward log output to Xcode debug console and/or device console (ASL).
3. Use NSLog visual format to log messages with log level addes as a prefix.
4. Laverage NLog visual format in your libraries (eg. cocoapods) to have dependence free logging utility.

## Simple usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.
In your source code include the librarary and use one of the logger methods eg.:

    TFLogDebug(@"message");

## Forwarding output 
Library forwards log input to the stdErr by default which is displayed by Xcode. In order to have your logs saved via ASL to device log add predefined ASL handler:

    TFLoggerAddHandler(TFASLLogHandler());

Default ASL log filter is set to display all messages except those with log levels DEBUG and INFO. That means:
- if you don't use NSLogToTFLoggerAdapter - ALL OF YOUR NSLogs WILL BE SENT TO THE DEVICE! (because by default NSLog a log level is ASL_LEVEL_ERR)
- if you DO use NSLogToTFLoggerAdapter (Recommended) - plain NSLog won't be sent to the device log (log level would be DEBUG which is below the filter line), except situations where explicitly set the log level using visual format to be ASL_LEVEL_WARNING or higher.

In case you want a different ASL filtering policy please use `asl_set_filter()` on your behalf.
ATTENTION: `TF_COMPILE_TIME_LOG_LEVEL` has precedence over all the other log levels.

If you want to forward logs somewhere else, simply create your own log handler as a block and add it to TFLogger.

## NSLog visual format

NSLogToTFLoggerAdapter function may be used to swizzle default NSLog behaviour. To do so include the following line in your source code:
`#define NSLog(...) NSLogToASLAdapter(module_name, __VA_ARGS__)`

This will cause the default NSLog statements to be forwarded to the `_TFLog` method which is TFLoggers' entry point.
Its behaviour will of course depend on TFLogger setup. By default it will cause your messages to be only shown in Xcode debugger.
Additionally if TFASLLogHandler is in use the the default log level of NSLog will be ASL_LEVEL_DEBUG instead of ASL_LEVEL_ERROR (which is a default for NSLog).
Additionally you can use visual log level formatting to change logging level. The syntax is like follows:

    NSLog(@"[m] something) - ASL_LEVEL_EMERG;
    NSLog(@"[a] something) - ASL_LEVEL_ALERT;
    NSLog(@"[c] something) - ASL_LEVEL_CRIT;
    NSLog(@"[e] something) - ASL_LEVEL_ERR;
    NSLog(@"[w] something) - ASL_LEVEL_WARNING;
    NSLog(@"[n] something) - ASL_LEVEL_NOTICE;
    NSLog(@"[i] something) - ASL_LEVEL_INFO;
    NSLog(@"[d] something) - ASL_LEVEL_DEBUG;

## Integration with other projects

TFLogger may be integrated with other projects using NSLog visual format. That means there is no direct dependency to logging facility in cocoapod library. Decision which logging framework you would use is postopned to a moment when you start using the library. At this time you can simply stay with default TFLogger implementation or easily forward all the logs to your favourite logging library eg. CocoaLumberjack using your own block handler.

In order to have this king of On Demand integration with TFLogger in your cocoapod library. Do the following:

1. Use NSLog with log visual formatting across all your implementation files in a library you develop.
2. Include the following in your Podspec: `s.prefix_header_contents = '#if NSLOG_TO_TFLOGGER_ENABLED', '#import <TFLogger/TFLogger.h>',  '#define NSLog(...) NSLogToTFLoggerAdapter(__VA_ARGS__)', '#endif'`
3. That's it. Now clients of your library are able to optionally turn on TFLogger integration, have your logs delivered with appropriate log levels and decide what to do with them.

In order to take advantage of a library that has TFLogger integration do the following:

1) In your projects Podfile add a dependency to TFLogger and to a pod you want to use:
```
target 'MyProject', :exclusive => true do
    pod "TFLogger"
    pod 'TFUtils'
end
```
2) Add a pod post_install step to activate visual format NSLog->TFLogger channel.

```
post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'NSLOG_TO_TFLOGGER_ENABLED=1'
        end
    end
end
```

## Installation

TFLogger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TFLogger"

## Author

Krzysztof Profic, kprofic@gmail.com

## License

TFLogger is available under the Apache v2. See the LICENSE file for more info.

