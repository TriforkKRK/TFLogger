# TFLogger

TFLogger allows you to do the following:

1. Use it as applicaiton wide logging facility (`TFLogDebug`, `TFLogError`, `...` macros)
Log messages with corresponding log levels will be printed directly into Xcode debug console and/or device console (ASL).

2. Swizzle NSLogs' default implementation and use it as dependency free logging utility for external modules or cocoapod libraries you develop.
Our NSLog implementation introduces log levels written using "visual format".

3. Implement your custom log handlers/adapters to forward messages to your desired destinations.
Eg. there is a CocoaLumberjack adapter available.

4. Use filters to debug only specific component you currently work on.

## Standard usage


TFLogger is very useful to categorize logged information according to the level of importance they convey. It enables you to do that by using the following macro definitions:
`TFLogEmergency` &nbsp;&nbsp;&nbsp;- The highest priority, usually reserved for catastrophic failures and reboot notices
`TFLogAlert` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-  A serious failure in a key system.
`TFLogCritical` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- A failure in a key system.
`TFLogError` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Something has failed.
`TFLogWarning` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Something is amiss and might fail if not corrected.
`TFLogNotice` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Things of moderate interest to the user or administrator.
`TFLogInfo` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- The lowest priority that you would normally log, and purely informational in nature.
`TFLogDebug` &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- The lowest priority, and normally not logged except for messages from the kernel.


The log level can be adjusted at any time using `TFLoggerSetBaselineLevel(NSInteger level)`.
Information logged on a lower level, than currently set, will be taken out.

##### NOTE
The above log macros are meant to be used on application level. In case you work on a library (eg. cocoapod, module) please refer to section


## Output forwarding


TFLogger allows you to select the destination of your logs, TFStdErrLogHandler is the default one and directs the logs to STDERR_FILENO - this is what you see in Xcode console.
TFASLLogHandler on the other hand forwards the logs to asl (Apple System Logger), they are stored on a device and can be read with Console application. In order to have your logs saved via ASL to device add this handler using:

    TFLoggerAddHandler(TFASLLogHandler());

If you want to forward logs somewhere else, simply create your own log handler as a block and add it to TFLogger using this method.

##### ATTENTION:
ASL has an internal predefined log filter. It is set to display all messages except those with log levels DEBUG and INFO.
In case you want different ASL filtering policy please use `asl_set_filter()` on your behalf.

##### INFO:
`TFLoggerBaselineLevel()` has precedence over all the other log levels.

## NSLog visual format

Standard NSLog implementation prints log messages to Xcode console (STDERR) and to ASL with logging level set to `ASL_LEVEL_ERR`. This is an equivalent of `TFLogError` with `TFASLLogHandler` being in use.

NSLog is a nice tool, it is part of `Foundation` framework and because of that it's always available - you don't need third party libraries to display logs. This is most probably the reason why developers still use NSLog on they daily basis - it's easy and it's always there. The sad thing about NSLog is:
- There is no way to define logging level - it's always ERROR. Usually you will need DEBUG, maybe WARNING.
- All NSLogs are forwarded to ASL thus they polute device logs.
- Xcode doesn't display the log levels

To address the above issues TFLogger is able to swizzle default NSLog implementation.
To do so include the following line in your source code:
`#define NSLog(...) NSLogToTFLoggerAdapter(module_name, __VA_ARGS__)`

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

##### Note:
The above mechanism is especially meant to use from external cocoapod libraries with swizzled NSLog (See the next chapter).
Of course you can also swizzle NSLog application wide - this way all NSLogs in the app will be nicely integrated with the whole TFLogger flow.

## External library integration

TFLogger may be integrated with other modules of your app using NSLog visual format. That means there won't be direct dependency to logging facility in your cocoapod library. Decision which logging framework one would like to use is postopned to a moment when you actually start using the library. At this time you can simply stay with default TFLogger implementation or easily forward all the logs to your favourite logging library (using your own block handler, CocoaLumberjack has a predefined handler: `TFCocoaLumberjackHandler`).

In order to have this kind of On Demand Integration with TFLogger in your cocoapod library - do the following:

1. Use NSLog with log visual formatting across all your implementation files in a library you develop.
2. Include the following in your Podspec: `s.prefix_header_contents = '#if NSLOG_TO_TFLOGGER_ENABLED', '#import <TFLogger/NSLogVisualFormat.h>',  '#define NSLog(...) NSLogToTFLoggerAdapter(@"YourPodName", __VA_ARGS__)', '#endif'`
3. That's it. Now clients of your library are able to optionally turn on TFLogger integration, have your logs delivered with appropriate log levels and decide what to do with them.

In order to take advantage of a library that has TFLogger integration do the following:

1) In your projects Podfile add a dependency to TFLogger and to a pod you want to use:
```
target 'MyProject', :exclusive => true do
    pod "TFLogger"
    pod 'OtherLibraryThatUsesNSLogVisualFormat'
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

The nice thing about this kind of dependency free integration using NSLog visual format is that in case one don't have TFLogger all the cococapod libraries just work. NSLog statements will simply cause to print logs using standard NSLog implementation.

##### Killer feature
The 'killer feature' here is that the decision which logging framework would handle logs delivered from a set of libraries you use is made aby the main application. You can even change logging framework at any time without modifying library source code.

## Installation

TFLogger is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

    pod "TFLogger"

## Changelog

### 1.0
- Initial release
- CocoaLumberjack adapter

## License

TFLogger is available under the Apache v2. See the LICENSE file for more info.

## Author

Krzysztof Profic, kprofic@gmail.com