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

#import "TFLogger.h"

int _extractLogLevelFromFormat(NSString *format)
{
    if ([format rangeOfString:@"[m]"].location != NSNotFound) return ASL_LEVEL_EMERG;
    if ([format rangeOfString:@"[a]"].location != NSNotFound) return ASL_LEVEL_ALERT;
    if ([format rangeOfString:@"[c]"].location != NSNotFound) return ASL_LEVEL_CRIT;
    if ([format rangeOfString:@"[e]"].location != NSNotFound) return ASL_LEVEL_ERR;
    if ([format rangeOfString:@"[w]"].location != NSNotFound) return ASL_LEVEL_WARNING;
    if ([format rangeOfString:@"[n]"].location != NSNotFound) return ASL_LEVEL_ERR;
    if ([format rangeOfString:@"[i]"].location != NSNotFound) return ASL_LEVEL_INFO;
    if ([format rangeOfString:@"[d]"].location != NSNotFound) return ASL_LEVEL_DEBUG;
    
    return ASL_LEVEL_DEBUG; // if not specified return the lowest log level - DEBUG
}

void NSLogToTFLoggerAdapter(NSString *format, ...) {
    int LOG_LEVEL = _extractLogLevelFromFormat(format);
    
    va_list argumentList;
    va_start(argumentList, format);
    
    // TODO: remove log level prefix from the parsed message
    NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                              arguments:argumentList];
    
    // TODO: can I remove switch ?
    switch (LOG_LEVEL) {
        case ASL_LEVEL_ERR:
            TFLogError(message);
            break;
        case ASL_LEVEL_WARNING:
            TFLogWarning(message);
            break;
            
        case ASL_LEVEL_INFO:
            TFLogInfo(message);
            break;
            
        case ASL_LEVEL_DEBUG:
            TFLogDebug(message);
            break;
            
        default:
            break;
    }

    va_end(argumentList);
}


//  Based on http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html

static void AddStderrOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asl_add_log_file(NULL, STDERR_FILENO);
    });
}


// TODO: _CMD, __LINE

#define __TF_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
AddStderrOnce(); \
va_list args; \
va_start(args, format); \
NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
va_end(args); \
}

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_EMERG
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, TFLogEmergency)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ALERT
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, TFLogAlert)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, TFLogCritical)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, TFLogError)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, TFLogWarning)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, TFLogNotice)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, TFLogInfo)
#endif

#if TF_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
__TF_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, TFLogDebug)
#endif

#undef __TF_MAKE_LOG_FUNCTION