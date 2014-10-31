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

/**
 *  TFLogger allows you to do the following:
 *
 *  1. Use it as applicaiton wide logging facility (`TFLogDebug`, `TFLogError`, `...` macros)
 *  Log messages with corresponding log levels will be printed directly into Xcode debug console and/or device console (ASL).
 *
 *  2. Swizzle NSLogs' default implementation and use it as dependency free logging utility for external modules or cocoapod libraries you develop.
 *  Our NSLog implementation introduces log levels written using "visual format".
 *
 *  3. Implement your custom log handlers/adapters to forward messages to your desired destinations.
 *  Eg. there is a CocoaLumberjack adapter available.
 *
 *  4. Use filters to debug only specific component you currently work on.
 */

#pragma mark - Macros

#define TFLogEmergency(format, ...)         _TFLog(ASL_LEVEL_EMERG,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogAlert(format, ...)             _TFLog(ASL_LEVEL_ALERT,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogCritical(format, ...)          _TFLog(ASL_LEVEL_CRIT,      @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogError(format, ...)             _TFLog(ASL_LEVEL_ERR,       @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogWarning(format, ...)           _TFLog(ASL_LEVEL_WARNING,   @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogNotice(format, ...)            _TFLog(ASL_LEVEL_NOTICE,    @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogInfo(format, ...)              _TFLog(ASL_LEVEL_INFO,      @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogDebug(format, ...)             _TFLog(ASL_LEVEL_DEBUG,     @"", __FILE__, __LINE__, (format), ##__VA_ARGS__)


#pragma mark - Setup

@class TFLogDescription;
typedef void (^TFLoggerLogHandler)  (TFLogDescription *desc);
typedef BOOL (^TFLoggerLogFilter)   (TFLogDescription *desc);

void TFLoggerAddLogHandler(TFLoggerLogHandler block);
void TFLoggerRemoveAllLogHandlers();

/**
 *  Module name can be used to group sets of log messages that come from different libraries.
 *  This can be used to easily create a filter that will only display messages from specific module.
 *  DefaultModuleName is used to mark all the log messages sent using TFLog[Emmergency, Alert, ...](format, ..) macros
 *  as messages belonging to this module name. It's used for convenience - you don't have to specify module name
 *  on every Log(..) call. As the log macros are meant to be used on application level (not library)
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
void TFLoggerSetFilter(TFLoggerLogFilter passFilter);


#pragma mark - Predefined log handlers
/**
 *  Standard Error output handler, forwards logs to standard error file descriptor (STDERR_FILENO).
 *  This handler is added to the TFLog streamline by default, so TFLogs are displayed by Xcode debugger.
 *  If you don't want your logs to be send to stderr use @see TFLoggerRemoveAllLogHandlers() in your appDelegate.
 */
TFLoggerLogHandler TFStdErrLogHandler;

/**
 *  Apple System Log Facility handler, forwards logs to asl. These are the ones saved on device and displayed by Console.app
 *  This handler is not added to the TFLog streamline by default. In order to have your logs saved on device do the following in your appDelegate:
 *  TFLoggerAddLogHandler(TFASLLogHandler());
 *  Default ASL log filter is set to display all messages except those with log levels DEBUG and INFO. That means:
 *  - if you don't use NSLogToTFLoggerAdapter - ALL OF YOUR NSLogs WILL BE SENT TO THE DEVICE! (because by default NSLog a log level is ASL_LEVEL_ERR)
 *  - if you DO use NSLogToTFLoggerAdapter (Recommended) - plain NSLog won't be sent to the device log (log level would be DEBUG which is below the filter line), 
 *  except situations where explicitly set the log level using visual format to be ASL_LEVEL_WARNING or higher.
 *  In case you want a different ASL filtering policy please use @see asl_set_filter() on your behalf.
 *  ATTENTION: TF_COMPILE_TIME_LOG_LEVEL has precedence over all the other log levels.
 */
TFLoggerLogHandler TFASLLogHandler;

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


#pragma mark - Privates

void _TFLog(int level, NSString * module, const char * file, int line, NSString *format, ...);

/**
 *  Holds log metadata of one log message. It is passed to log handlers and filters as parameter
 *  We wasn't able to use structs as ARC forbids using Objective-C types within.
 */
@interface TFLogDescription : NSObject

@property (nonatomic, strong, readonly) NSString  *module;
@property (nonatomic, assign, readonly) NSInteger level;
@property (nonatomic, strong, readonly) NSString  *file;
@property (nonatomic, assign, readonly) NSInteger line;
@property (nonatomic, strong, readonly) NSString  *message;
@property (nonatomic, strong, readonly) NSDate    *date;

@end

