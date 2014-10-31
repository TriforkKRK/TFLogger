/*
 * Created by Krzysztof Profic on 30/10/14.
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


#import <TFLogger/TFLogger.h>

#pragma mark - NSLog visual format

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

int _extractLogLevelFromFormat(NSString *format);
NSString * _formatWithoutVisualLogLevelPrefix(NSString *format);
