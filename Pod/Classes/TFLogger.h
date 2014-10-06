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

typedef void (^TFLoggerHandler)(int level, NSString *location,  NSString *msg);
// TODO: typedef for handlers

void TFLoggerAddHandler(TFLoggerHandler handler);
void TFLoggerRemoveAllHandlers();

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

// One can define TF_COMPILE_TIME_LOG_LEVEL to set compile time log levels
// all the log operations with levels that are below this setting will be converted to NOOP
// if not defined ASL_LEVEL_DEBUG is set on DEBUG and ASL_LEVEL_ERR on RELEASE.
#ifndef TF_COMPILE_TIME_LOG_LEVEL
    #if DEBUG
        #define TF_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
    #else
        #define TF_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_ERR
    #endif
#endif


#pragma mark - Macros

#define TFLogEmergency(format, ...)     _TFLog(ASL_LEVEL_EMERG, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogAlert(format, ...)         _TFLog(ASL_LEVEL_ALERT, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogCritical(format, ...)      _TFLog(ASL_LEVEL_CRIT, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogError(format, ...)         _TFLog(ASL_LEVEL_ERR, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogWarning(format, ...)       _TFLog(ASL_LEVEL_WARNING, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogNotice(format, ...)        _TFLog(ASL_LEVEL_NOTICE, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogInfo(format, ...)          _TFLog(ASL_LEVEL_INFO, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogDebug(format, ...)         _TFLog(ASL_LEVEL_DEBUG, __FILE__, __LINE__, (format), ##__VA_ARGS__)


#pragma mark - NSLog visual format adapting

/**
 *  NSLogToTFLoggerAdapter function may be used to swizzle default NSLog behaviour. To do so include the following line in your source code:
 *  #define NSLog(...) NSLogToASLAdapter(__VA_ARGS__)
 *  This will cause the default NSLog statements to be forwarded to the @see _TFLog method which is TFLoggers' entry point.
 *  Its behaviour will of course depend on TFLogger setup. By default it will cause your messages to be only shown in Xcode debugger.
 *  Additionally if TFASLLogHandler is in use the the default log level of NSLog will be ASL_LEVEL_DEBUG instead of ASL_LEVEL_ERROR (which is a default for NSLog).
 *  Additionally you can use visual log level formatting to change logging level. The syntax is like follows:
 *
 *  NSLog(@"[m] something) - ASL_LEVEL_EMERG;
 *  NSLog(@"[a] something) - ASL_LEVEL_ALERT;
 *  NSLog(@"[c] something) - ASL_LEVEL_CRIT;
 *  NSLog(@"[e] something) - ASL_LEVEL_ERR;
 *  NSLog(@"[w] something) - ASL_LEVEL_WARNING;
 *  NSLog(@"[n] something) - ASL_LEVEL_NOTICE;
 *  NSLog(@"[i] something) - ASL_LEVEL_INFO;
 *  NSLog(@"[d] something) - ASL_LEVEL_DEBUG;
 */

#define NSLogToTFLoggerAdapter(format, ...) { \
    int LOG_LEVEL = _extractLogLevelFromFormat(format); \
    NSString *FRMT = _formatWithoutVisualLogLevelPrefix(format);\
    _TFLog(LOG_LEVEL, __FILE__, __LINE__, FRMT, ##__VA_ARGS__); \
}
// TODO: NSLogToStdErr, NSLogToASL


#pragma mark - Privates used by macros
int _extractLogLevelFromFormat(NSString *format);
NSString * _formatWithoutVisualLogLevelPrefix(NSString *format);
void _TFLog(int level, const char * file, int line, NSString *format, ...);
