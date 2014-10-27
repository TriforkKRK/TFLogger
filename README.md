# TFLogger

TFLogger allows you to do the following:

1. Use it as applicaiton wide logging facility (`TFLogDebug`, `TFLogError`, `...` macros)
Log messages with corresponding log levels will be printed directly into Xcode debug console and/or device console (ASL).

2. Swizzle NSLogs' default implementation and use it as dependency free logging utility for external modules or cocoapod libraries you develop.
Our NSLog implementation introduces log levels written using "visual format".

3. Implement your custom log handlers/adapters to forward messages to your desired destinations.
Eg. there is a CocoaLumberjack adapter available.

4. Use filters to debug only specific component you currently work on.

## Simple usage

There is an example project where you can have a look at common use cases.
To run example project clone the repo, and run `pod install` from the Example directory first.

To start using TFLogger as logging tool in your own source code, first include the librarary header as you do with all the other libraries and then use one of the logger methods eg.:

    TFLogDebug(@"message");

## Forwarding output 
Library forwards log messages by default to the stdErr which is a channel displayed by Xcode' debugger. In order to have your logs saved via ASL to device log add predefined ASL handler:

    TFLoggerAddHandler(TFASLLogHandler());

If you want to forward logs somewhere else, simply create your own log handler as a block and add it to TFLogger.

#####ATTENTION:
Default ASL log filter is set to display all messages except those with log levels DEBUG and INFO.
That means - ALL OF YOUR NSLogs WILL BE SENT TO THE DEVICE because default NSLog log level is set to ASL_LEVEL_ERR.
However if you swizzle NSLog using NSLogToTFLoggerAdapter (@see NSLog visual format) - plain NSLog won't be sent to the device log (log level would be DEBUG which is below the bottm line), except situations where you explicitly set the log level using visual format to be ASL_LEVEL_WARNING or higher. In case you want a different ASL filtering policy please use `asl_set_filter()` on your behalf.
INFO: `TFLoggerBaselineLevel()` has precedence over all the other log levels.

## NSLog visual format

NSLogToTFLoggerAdapter function may be used to swizzle default NSLog behaviour. To do so include the following line in your source code:
`#define NSLog(...) NSLogToASLAdapter(module_name, __VA_ARGS__)`

This will cause the default NSLog statements to be forwarded to the `_TFLog` method which is TFLoggers' entry point.
Its behaviour will of course depend on TFLogger setup. By default it will cause your messages to be only shown in Xcode debugger.
Additionally if TFASLLogHandler is in use the the default log level of NSLog will be ASL_LEVEL_DEBUG instead of ASL_LEVEL_ERROR.
The key feature here is NSLog visual formatting, which you can use to change logging levels explicitly in log messages using such syntax:

    NSLog(@"[m] something) - ASL_LEVEL_EMERG;
    NSLog(@"[a] something) - ASL_LEVEL_ALERT;
    NSLog(@"[c] something) - ASL_LEVEL_CRIT;
    NSLog(@"[e] something) - ASL_LEVEL_ERR;
    NSLog(@"[w] something) - ASL_LEVEL_WARNING;
    NSLog(@"[n] something) - ASL_LEVEL_NOTICE;
    NSLog(@"[i] something) - ASL_LEVEL_INFO;
    NSLog(@"[d] something) - ASL_LEVEL_DEBUG;

## Integration with other projects

TFLogger may be integrated with other projects using NSLog visual format. That means there won't be direct dependency to logging facility in your cocoapod library. Decision which logging framework one would like to use is postopned to a moment when you actually start using the library. At this time you can simply stay with default TFLogger implementation or easily forward all the logs to your favourite logging library eg. CocoaLumberjack using your own block handler.

In order to have this kind of On Demand Integration with TFLogger in your cocoapod library - do the following:

1. Use NSLog with log visual formatting across all your implementation files in a library you develop.
2. Include the following in your Podspec: `s.prefix_header_contents = '#if NSLOG_TO_TFLOGGER_ENABLED', '#import <TFLogger/TFLogger.h>',  '#define NSLog(...) NSLogToTFLoggerAdapter(@"YourPodName", __VA_ARGS__)', '#endif'`
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

The nice thing about this kind of dependency free integration using NSLog visual format is that in case one don't have TFLogger all the cococapod libraries just work. NSLog statements will simply cause to print logs using standard NSLog implementation. The only difference would be that there will be sometimes some sort of prefix in these logging messages (eg. `[d]`). 

Moreover - you're not constrained to TFLogger implementation, with NSLog visual format in your cocoapods `NSLogToASLAdapter` in action and custom log handler you can have all your logs processed by third pardy logging utility eg. `CocoaLumberjack (DDLog)`.

## Installation

TFLogger is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TFLogger"

## Author

Krzysztof Profic, kprofic@gmail.com

## License

TFLogger is available under the Apache v2. See the LICENSE file for more info.

