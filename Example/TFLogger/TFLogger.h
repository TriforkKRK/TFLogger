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

// TODO: remove host info from logged message if possible
// TODO: miliseconds in datetime

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


#define TFLogEmergency(format, ...)     _TFLog(ASL_LEVEL_EMERG, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogAlert(format, ...)         _TFLog(ASL_LEVEL_ALERT, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogCritical(format, ...)      _TFLog(ASL_LEVEL_CRIT, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogError(format, ...)         _TFLog(ASL_LEVEL_ERR, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogWarning(format, ...)       _TFLog(ASL_LEVEL_WARNING, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogNotice(format, ...)        _TFLog(ASL_LEVEL_NOTICE, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogInfo(format, ...)          _TFLog(ASL_LEVEL_INFO, __FILE__, __LINE__, (format), ##__VA_ARGS__)
#define TFLogDebug(format, ...)         _TFLog(ASL_LEVEL_DEBUG, __FILE__, __LINE__, (format), ##__VA_ARGS__)


// One can use NSLogToTFLoggerAdapter function to swizzle default NSLog behaviour. To do so include the following line is your source code:
// #define NSLog(...) NSLogToASLAdapter(__VA_ARGS__)
// this will cause the default NSLog statements to be treaten as asl logs with log level set to ASL_LEVEL_DEBUG instead of ASL_LEVEL_ERROR (which is a default for NSLog). Additionaly you can use visual log level formatting with the following syntax:

// NSLog(@"[m] something) - ASL_LEVEL_EMERG;
// NSLog(@"[a] something) - ASL_LEVEL_ALERT;
// NSLog(@"[c] something) - ASL_LEVEL_CRIT;
// NSLog(@"[e] something) - ASL_LEVEL_ERR;
// NSLog(@"[w] something) - ASL_LEVEL_WARNING;
// NSLog(@"[n] something) - ASL_LEVEL_NOTICE;
// NSLog(@"[i] something) - ASL_LEVEL_INFO;
// NSLog(@"[d] something) - ASL_LEVEL_DEBUG;

#define NSLogToTFLoggerAdapter(format, ...) { \
    int LOG_LEVEL = _extractLogLevelFromFormat(format); \
    NSString *FRMT = _formatWithoutVisualLogLevelPrefix(format);\
    _TFLog(LOG_LEVEL, __FILE__, __LINE__, FRMT, ##__VA_ARGS__); \
}



// Private

int _extractLogLevelFromFormat(NSString *format);
NSString * _formatWithoutVisualLogLevelPrefix(NSString *format);
void _TFLog(int level, const char * file, int line, NSString *format, ...);
