//
//  TFLogger+CocoaLumberjack.m
//  Pods
//
//  Created by Krzysztof Profic on 21/10/14.
//
//

#import "TFLoggerHandlerToCocoaLumberjackAdapter.h"

TFLoggerHandler CocoaLumberjackToTFLoggerHandlerAdapter =  ^(TFLogDescription *desc)
{
    int level, flag;
    switch (desc.level) {
        case ASL_LEVEL_DEBUG:
            level = LOG_LEVEL_DEBUG;
            flag  = LOG_FLAG_DEBUG;
            break;
            
        case ASL_LEVEL_INFO:
        case ASL_LEVEL_NOTICE:
            level = LOG_LEVEL_INFO;
            flag  = LOG_FLAG_INFO;
            break;
            
        case ASL_LEVEL_WARNING:
            level = LOG_LEVEL_WARN;
            flag  = LOG_FLAG_WARN;
            break;
            
        case ASL_LEVEL_ERR:
        case ASL_LEVEL_CRIT:
        case ASL_LEVEL_ALERT:
        case ASL_LEVEL_EMERG:
            level = LOG_LEVEL_ERROR;
            flag  = LOG_FLAG_ERROR;
            break;
            
        default:
            level = ASL_LEVEL_DEBUG;
            flag  = LOG_FLAG_DEBUG;
            break;
    }
    
    [DDLog log:LOG_ASYNC_ENABLED
         level:level
          flag:flag
       context:0
          file:[[desc file] UTF8String]
      function:NULL
          line:(int)desc.line
           tag:nil
        format:desc.message, nil];
};