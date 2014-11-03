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
#import <pthread.h>

/**
 *  Implementaiton was inspired by:
 *  http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
 *
 *  Apple "Logging Errirs and Warnings" documentation reference:
 *  https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/LoggingErrorsAndWarnings.html
 */

pthread_mutex_t _loggingCriticalSectionMutex();
NSMutableArray* _currentLogHandlers();
NSString * _nslogFormattedPrefix(BOOL excludeAppname);
NSString * _levelDescription(NSInteger level);
static NSInteger _baselineLevel = ASL_LEVEL_ERR;
static NSString * _moduleName;
static TFLoggerLogFilter _passFilter;


#pragma mark - Log description entity

@interface TFLogDescription()

@property (nonatomic, strong, readwrite) NSString  *module;
@property (nonatomic, assign, readwrite) NSInteger level;
@property (nonatomic, strong, readwrite) NSString  *file;
@property (nonatomic, assign, readwrite) NSInteger line;
@property (nonatomic, strong, readwrite) NSString  *message;
@property (nonatomic, strong, readwrite) NSDate    *date;


+ (TFLogDescription *)withModule:(NSString *)module level:(NSInteger)level file:(NSString *)file line:(NSInteger)line message:(NSString *)message;

@end

@implementation TFLogDescription

+ (TFLogDescription *)withModule:(NSString *)module level:(NSInteger)level file:(NSString *)file line:(NSInteger)line message:(NSString *)message
{
    TFLogDescription *desc = [[TFLogDescription alloc] init];
    desc.module  = module;
    desc.level   = level;
    desc.file    = file;
    desc.line    = line;
    desc.message = message;
    desc.date    = [NSDate date];
    
    return desc;
}
@end


#pragma mark - Setup

void TFLoggerAddLogHandler(TFLoggerLogHandler logHandler)
{
    NSMutableArray * loggers = _currentLogHandlers();
    [loggers addObject:[logHandler copy]];
}

void TFLoggerRemoveAllLogHandlers()
{
    [_currentLogHandlers() removeAllObjects];
}

NSString * TFLoggerDefaultModuleName()
{
    NSString * name;
    pthread_mutex_t loggingCriticalSection = _loggingCriticalSectionMutex();
    pthread_mutex_lock(&loggingCriticalSection);
    name = _moduleName;
    pthread_mutex_unlock(&loggingCriticalSection);
    return name;
}

void TFLoggerSetDefaultModuleName(NSString * name)
{
    pthread_mutex_t loggingCriticalSection = _loggingCriticalSectionMutex();
    pthread_mutex_lock(&loggingCriticalSection);
    _moduleName = [name copy];
    pthread_mutex_unlock(&loggingCriticalSection);
}

void TFLoggerSetFilter(TFLoggerLogFilter passFilter)
{
    _passFilter = [passFilter copy];
}

NSInteger TFLoggerBaselineLevel()
{
    NSInteger level;
    pthread_mutex_t loggingCriticalSection = _loggingCriticalSectionMutex();
    pthread_mutex_lock(&loggingCriticalSection);
    level = _baselineLevel;
    pthread_mutex_unlock(&loggingCriticalSection);
    return level;
}

void TFLoggerSetBaselineLevel(NSInteger level)
{
    pthread_mutex_t loggingCriticalSection = _loggingCriticalSectionMutex();
    pthread_mutex_lock(&loggingCriticalSection);
    _baselineLevel = level;
    pthread_mutex_unlock(&loggingCriticalSection);
}

#pragma mark - Default Log Handlers

TFLoggerLogHandler TFStdErrLogHandler =  ^(TFLogDescription *desc)
{
    NSString * prefix = _nslogFormattedPrefix(YES);
    NSString * prefixWithLocation;
    if ([desc.module length] > 0) {
        prefixWithLocation = [NSString stringWithFormat:@"%@ [%@] %@:%ld", prefix, desc.module, desc.file, (long)desc.line];    // add module info
    }
    else {
        prefixWithLocation = [NSString stringWithFormat:@"%@ %@:%ld", prefix, desc.file, (long)desc.line];    // no module info
    }
    
    NSString * formattedMsg = [NSString stringWithFormat:@"%@ <%@> %@", prefixWithLocation, _levelDescription(desc.level), desc.message];
    CFStringRef cfFormattedMsg = CFStringCreateWithCString(NULL, [formattedMsg UTF8String], kCFStringEncodingUTF8);
    CFShow(cfFormattedMsg);
    CFRelease(cfFormattedMsg);
};

TFLoggerLogHandler TFASLLogHandler =  ^(TFLogDescription *desc)
{
    NSString * formattedMsg = [NSString stringWithFormat:@"%@:%ld %@", desc.file, (long)desc.line, desc.message];
    asl_log(NULL, NULL, (int)desc.level, "%s", [formattedMsg UTF8String]);
};


#pragma mark - Private

void _TFLog(int level, NSString *module, const char *file, int line, NSString *format, ...)
{
    pthread_mutex_t loggingCriticalSection = _loggingCriticalSectionMutex();
    pthread_mutex_lock(&loggingCriticalSection);
    
    if (TFLoggerBaselineLevel() < level) return;
    
    NSString * moduleName = module.length > 0 ? module : TFLoggerDefaultModuleName();
    NSString * path = [NSString stringWithUTF8String:file];
    
    va_list argumentList;
    va_start(argumentList, format);
    NSString * message = [[NSString alloc] initWithFormat:format
                                                arguments:argumentList];
    va_end(argumentList);
    
    TFLogDescription *desc = [TFLogDescription withModule:moduleName level:level file:[path lastPathComponent] line:line message:message];
    if (_passFilter && _passFilter(desc) == NO) return;
    
    for (TFLoggerLogHandler logHandler in [_currentLogHandlers() copy]) { // copied to iterate over immutable
        logHandler(desc);
    }
    
    pthread_mutex_unlock(&loggingCriticalSection);
}

pthread_mutex_t _loggingCriticalSectionMutex()
{
    static pthread_mutex_t mutex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutexattr_t m_attr;
        pthread_mutexattr_init(&m_attr);
        pthread_mutexattr_settype(&m_attr, PTHREAD_MUTEX_RECURSIVE);
        pthread_mutex_init(&mutex, &m_attr);
    });
    return mutex;
}

NSString * _levelDescription(NSInteger level)
{
    switch (level) {
        case ASL_LEVEL_DEBUG:
            return @ASL_STRING_DEBUG;

        case ASL_LEVEL_INFO:
            return @ASL_STRING_INFO;
        
        case ASL_LEVEL_NOTICE:
            return @ASL_STRING_NOTICE;
            
        case ASL_LEVEL_WARNING:
            return @ASL_STRING_WARNING;
            
        case ASL_LEVEL_ERR:
            return @ASL_STRING_ERR;
            
        case ASL_LEVEL_CRIT:
            return @ASL_STRING_CRIT;
            
        case ASL_LEVEL_ALERT:
            return @ASL_STRING_ALERT;
            
        case ASL_LEVEL_EMERG:
            return @ASL_STRING_EMERG;
            
        default:
            return @ASL_STRING_DEBUG;
    }
}

NSString * _nslogFormattedPrefix(BOOL excludeAppname)
{
    NSDate * d = [NSDate date];
    time_t time = [d timeIntervalSince1970];
    struct tm timeStruct;
    localtime_r(&time, &timeStruct);
    char buffer[80];
    strftime(buffer, 80, "%Y-%m-%d %H:%M:%S", &timeStruct);  // yyyy-MM-dd HH:mm:ss:SSS
    NSTimeInterval epoch = [d timeIntervalSinceReferenceDate];
    int milliseconds = (int)((epoch - floor(epoch)) * 1000);
    NSString *dateStr = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    
    NSString * fmt = [NSString stringWithFormat:@"%@:%03d", dateStr, milliseconds];
    if (excludeAppname) return fmt;
    
    NSString * appName = [[NSProcessInfo processInfo] processName];
    NSString * processID = [NSString stringWithFormat:@"%i", (int)getpid()];
    NSString * tid = [NSString stringWithFormat:@"%x", pthread_mach_thread_np(pthread_self())];
    return [NSString stringWithFormat:@"%@ %@[%@:%@]", fmt, appName, processID, tid]; // appName, processID, threadID
}

NSMutableArray *_currentLogHandlers()
{
    static NSMutableArray * blocks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blocks = [NSMutableArray arrayWithObject:TFStdErrLogHandler]; // by default all logs are sent to StdErr to be displayed in XCode debug console
    });
    return blocks;
}

