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

// One can use NSLogToTFLoggerAdapter function to swizzle default NSLog behaviour. To do so include the following line is your source code:
// #define NSLog(...) NSLogToASLAdapter(__VA_ARGS__)
// this will cause the default NSLog statements to be treaten as asl logs with log level set to ASL_LEVEL_DEBUG instead of ASL_LEVEL_ERROR (which is a default for NSLog). Additionaly you can use visual log level formatting:
// NSLog(@"[w] something") - ASL_LEVEL_WARN
// NSLog(@"[d] debug")     - ASL_LEVEL_DEBUG
// aso...

void NSLogToTFLoggerAdapter(NSString *format, ...);

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

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_EMERG
void TFLogEmergency(NSString *format, ...);
#else
#define TFLogEmergency(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ALERT
void TFLogAlert(NSString *format, ...);
#else
#define TFLogAlert(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
void TFLogCritical(NSString *format, ...);
#else
#define TFLogCritical(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
void TFLogError(NSString *format, ...);
#else
#define TFLogError(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
void TFLogWarning(NSString *format, ...);
#else
#define TFLogWarning(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
void TFLogNotice(NSString *format, ...);
#else
#define TFLogNotice(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
void TFLogInfo(NSString *format, ...);
#else
#define TFLogInfo(...)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_DEBUG
void TFLogDebug(NSString *format, ...);
#else
#define TFLogDebug(...)
#endif


