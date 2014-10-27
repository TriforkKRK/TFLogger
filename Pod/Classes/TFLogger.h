/*
 * Created by Krzysztof Profic on 14/04/14.
 * Copyright (c) 2014 Trifork A/S.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import <Foundation/Foundation.h>
#import "asl.h"

#pragma mark - Log description entity
/**
 * Holds log metadata of one log message. It is passed to log handlers and filters as parameter
 * We wasn't able to use structs as ARC forbids using Objective-C types within.
 */
@interface TFLogDescription : NSObject

@property (nonatomic, strong) NSString  *module;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, strong) NSString  *file;
@property (nonatomic, assign) NSInteger line;
@property (nonatomic, strong) NSString  *message;
@property (nonatomic, strong) NSDate    *date;

+ (TFLogDescription *)withModule:(NSString *)module level:(NSInteger)level file:(NSString *)file line:(NSInteger)line message:(NSString *)message;

@end


#pragma mark - TFLogger setup

typedef void (^TFLoggerHandler)(TFLogDescription *desc);
typedef BOOL (^TFLoggerFiltering)(TFLogDescription *desc);

void TFLoggerAddHandler(TFLoggerHandler handler);
void TFLoggerRemoveAllHandlers();

/**
 *  Module name can be used to group sets of log messages that come from different libraries.
 *  This can be used to easily create a filter that will only display messages from specific module.
 *  DefaultModuleName is used to mark all the log messages sent using TFLog[Emmergency, Alert, ...](format, ..) macros
 *  as messages belonging to this module name. It's used for convenience - you don't have to specify module name
 *  on every Log(..) call. As the log macros are ment to be used on application level (not library)
 *  DefaultModuleName is usually used to set the name being your application name, this way one can 
 *  differentiate applicaiton level messages from library/submodule logs.
 *  To see how you can use module name in your submodules @see NSLogToTFLoggerAdapter.
 */
NSString * TFLoggerDefaultModuleName();
void TFLoggerSetDefaultModuleName(NSString * name);

/**
 *  The log message will only be processed if it has a log level that greater or equal to TFLoggerBaselineLevel and
 *  when it will pass the filter specified by this function. It is by default not set which means - all messages will pass.
 *  One can use filters strictly for debugging purposes - eg. to display only messages from specific module.
 *  It can also be used to implement pass rule that are more advanced than simple log level to basine log level relationship.
 */
void TFLoggerSetFilter(TFLoggerFiltering passFilter);


#pragma mark - Predefined log handlers
/**
 *  Standard Error output handler, forwards logs to standard error file descriptor (STDERR_FILENO).
 *  This handler is added to the TFLog streamline by default, so TFLogs are displayed by Xcode debugger.
 *  If you don't want your logs to be send to stderr use @see TFLoggerRemoveAllHandlers() in your appDelegate.
 */
TFLoggerHandler TFStdErrLogHandler;

/**
 *  Apple System Log Facility handler, forwards logs to asl. These are the ones saved on device and displayed by Console.app
 *  This handler is not added to the TFLog streamline by default. In order to have your logs saved on device do the following in your appDelegate:
 *  TFLoggerAddHandler(TFASLLogHandler());
 *  Default ASL log filter is set to display all messages except those with log levels DEBUG and INFO. That means:
 *  - if you don't use NSLogToTFLoggerAdapter - ALL OF YOUR NSLogs WILL BE SENT TO THE DEVICE! (because by default NSLog a log level is ASL_LEVEL_ERR)
 *  - if you DO use NSLogToTFLoggerAdapter (Recommended) - plain NSLog won't be sent to the device log (log level would be DEBUG which is below the filter line), 
 *  except situations where explicitly set the log level using visual format to be ASL_LEVEL_WARNING or higher.
 *  In case you want a different ASL filtering policy please use @see asl_set_filter() on your behalf.
 *  ATTENTION: TF_COMPILE_TIME_LOG_LEVEL has precedence over all the other log levels.
 */
TFLoggerHandler TFASLLogHandler;

/**
 *  TFLoggerBaselineLevel is used by TFLogger to decide weather or not specific log should be processed
 *  Messages with log levels that are below this setting will be stripped as soon as they reach @see _TFLog
 *  By default it is set to be ASL_LEVEL_ERR which is usually a good choice for RELEASE configuration
 *  You can change the value as desired. Eg. it is a common practice to do the following:
 *  #ifdef DEBUG
 *      TFLoggerSetBaselineLevel(ASL_LEVEL_DEBUG);
 *  #endif
 */
NSInteger TFLoggerBaselineLevel();
void TFLoggerSetBaselineLevel(NSInteger level);


#pragma mark - Macros

#define TFLogEmergency(format, ...)         _TFLog(ASL_LEVEL_EMERG,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogAlert(format, ...)             _TFLog(ASL_LEVEL_ALERT,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogCritical(format, ...)          _TFLog(ASL_LEVEL_CRIT,      @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogError(format, ...)             _TFLog(ASL_LEVEL_ERR,       @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogWarning(format, ...)           _TFLog(ASL_LEVEL_WARNING,   @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogNotice(format, ...)            _TFLog(ASL_LEVEL_NOTICE,    @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogInfo(format, ...)              _TFLog(ASL_LEVEL_INFO,      @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogDebug(format, ...)             _TFLog(ASL_LEVEL_DEBUG,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)


#pragma mark - NSLog visual format adapting

/**
 *  NSLogToTFLoggerAdapter function may be used to swizzle default NSLog behaviour. To do so include the following line in your source code:
 *  #define NSLog(...) NSLogToASLAdapter(module_name, __VA_ARGS__)
 *  This will cause the default NSLog statements to be forwarded to the @see _TFLog method which is the TFLoggers' entry point.
 *  Its' behaviour will of course depend on TFLogger setup.
 *  By default it will cause your future NSLog messages to be only shown in Xcode debugger.
 *  INFO: this technique is meant to be used as a dependency free logging tool for submodules/cocoapod libraries.
 *  In case you want to use TFLogger on application level please refer to TFLogDebug, TFLogInfo
 *
 *  @param module_name - it is used to group log statements belonging to the same module/library.
 *  It is usually used when NSLogToTFLoggerAdapter is used to provide dependency free logging in cocoapod library.
 *  In this case module_name would be a name of cocoapod library. To read more about dependency free logging in modules/cocoapods see the README.md
 *  This param is required - if you pass nil or empty string TFLoggerDefaultModuleName will be used.
 *
 *  @param format - NSLog like formatted message. Notice that you can use visual log level formatting to specify logging level.
 *  The syntax is like follows:
 *
 *  NSLog(@"[m] something) - ASL_LEVEL_EMERG;
 *  NSLog(@"[a] something) - ASL_LEVEL_ALERT;
 *  NSLog(@"[c] something) - ASL_LEVEL_CRIT;
 *  NSLog(@"[e] something) - ASL_LEVEL_ERR;
 *  NSLog(@"[w] something) - ASL_LEVEL_WARNING;
 *  NSLog(@"[n] something) - ASL_LEVEL_NOTICE;
 *  NSLog(@"[i] something) - ASL_LEVEL_INFO;
 *  NSLog(@"[d] something) - ASL_LEVEL_DEBUG;
 *
 *  IMPORTANT: NSLog log messages backed by NSLogToTFLoggerAdapter will have different logging level by default.
 *  Normally NSLog is set up by Apple to send logs with ASL_LEVEL_ERROR. NSLogToTFLoggerAdapter changes that default be ASL_LEVEL_DEBUG.
 *  That means - in case a log level is not explicitly specified using the above visual format, it will be set to ASL_LEVEL_DEBUG.
 */
#define NSLogToTFLoggerAdapter(module_name, format, ...) { \
    int LOG_LEVEL = _extractLogLevelFromFormat(format); \
    NSString *FRMT = _formatWithoutVisualLogLevelPrefix(format); \
    _TFLog(LOG_LEVEL, module_name, __FILE__, __LINE__, FRMT, ##__VA_ARGS__); \
}


#pragma mark - Privates used by macros

int _extractLogLevelFromFormat(NSString *format);
NSString * _formatWithoutVisualLogLevelPrefix(NSString *format);
void _TFLog(int level, NSString * module, const char * file, int line, NSString *format, ...);
