//
//  TFLogging.m
//  nslogtest
//
//  Created by Krzysztof Profic on 11/09/14.
//  Copyright (c) 2014 trifork. All rights reserved.
//

#import "TFLogging.h"

int _extractLogLevelFromFormat(NSString *format)
{
    if ([format rangeOfString:@"[e]"].location != NSNotFound) return ASL_LEVEL_ERR;
    if ([format rangeOfString:@"[w]"].location != NSNotFound) return ASL_LEVEL_WARNING;
    if ([format rangeOfString:@"[i]"].location != NSNotFound) return ASL_LEVEL_INFO;
    if ([format rangeOfString:@"[d]"].location != NSNotFound) return ASL_LEVEL_DEBUG;
    
    return ASL_LEVEL_DEBUG; // by default it's debug
}

void NSLogToASLAdapter(NSString *format, ...) {
    int LOG_LEVEL = _extractLogLevelFromFormat(format);
    
    va_list argumentList;
    va_start(argumentList, format);
    
    // TODO: remove log level prefix
    NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                              arguments:argumentList];
    
    // todo can I remove switch ?
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

#define __TF_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
AddStderrOnce(); \
va_list args; \
va_start(args, format); \
NSString * msg = [[NSMutableString alloc] initWithFormat:@"%s %d", (__FILE__), (__LINE__)]; \
NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
asl_log(NULL, NULL, (LEVEL), "%s", [msg UTF8String]); \
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