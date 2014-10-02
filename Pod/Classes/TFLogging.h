//
//  TFLogging.h
//  nslogtest
//
//  Created by Krzysztof Profic on 11/09/14.
//  Copyright (c) 2014 trifork. All rights reserved.
//

@import Foundation;
#import "asl.h"

// One can use NSLogToASLAdapter function to swizzle default NSLog behaviour. To do so include the following line is your source code:
// #define NSLog(...) NSLogToASLAdapter(__VA_ARGS__)
void NSLogToASLAdapter(NSString *format, ...);

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


