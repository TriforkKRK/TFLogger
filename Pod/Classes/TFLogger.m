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
//  Based on http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
//  https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/LoggingErrorsAndWarnings.html

NSMutableArray* _loggerHandlers();
NSString * _nslogFormattedPrefix(BOOL excludeAppname);
NSString * _levelDescription(int level);

void TFLoggerAddHandler(TFLoggerHandler handler)
{
    NSMutableArray * loggers = _loggerHandlers();
    [loggers addObject:[handler copy]];
}

void TFLoggerRemoveAllHandlers()
{
    [_loggerHandlers() removeAllObjects];
}

#pragma mark - Default Log Handlers

TFLoggerHandler TFStdErrLogHandler =  ^(int level, NSString *location, NSString *msg) {
    NSString * prefix = _nslogFormattedPrefix(YES);
    NSString * formattedMsg = [NSString stringWithFormat:@"%@ %@ <%@> %@", prefix, location, _levelDescription(level), msg];
    CFStringRef cfFormattedMsg = CFStringCreateWithCString(NULL, [formattedMsg UTF8String], kCFStringEncodingUTF8);
    CFShow(cfFormattedMsg);
    CFRelease(cfFormattedMsg);
};

// TODO: Console.app http://stackoverflow.com/questions/13473864/use-asl-to-log-to-console-app
TFLoggerHandler TFASLLogHandler =  ^(int level, NSString *location, NSString *msg) {
    // TODO: hang log level saved on device
    NSString * formattedMsg = [NSString stringWithFormat:@"%@ %@", location, msg];
    asl_log(NULL, NULL, level, "%s", [formattedMsg UTF8String]);
};


#pragma mark - Private

void _TFLog(int level, const char * file, int line, NSString *format, ...)
{
    // TODO: ??
    if (TF_COMPILE_TIME_LOG_LEVEL < level) return;
    
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString * path = [NSString stringWithUTF8String:file];
    NSString * message = [[NSString alloc] initWithFormat:format
                                                arguments:argumentList];
    NSString * location = [NSString stringWithFormat:@"%@:%d",[path lastPathComponent], line];
    
    for (TFLoggerHandler handler in [_loggerHandlers() copy]) { // copied to iterate over immutable
        handler(level, location, message);
    }
    va_end(argumentList);
}

NSString * _levelDescription(int level)
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

NSMutableArray *_loggerHandlers()
{
    static NSMutableArray * blocks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blocks = [NSMutableArray arrayWithObject:TFStdErrLogHandler]; // by default all logs are sent to StdErr to be displayed in XCode debug console
    });
    return blocks;
}

int _extractLogLevelFromFormat(NSString *format)
{
    if ([format rangeOfString:@"[m]"].location != NSNotFound) return ASL_LEVEL_EMERG;
    if ([format rangeOfString:@"[a]"].location != NSNotFound) return ASL_LEVEL_ALERT;
    if ([format rangeOfString:@"[c]"].location != NSNotFound) return ASL_LEVEL_CRIT;
    if ([format rangeOfString:@"[e]"].location != NSNotFound) return ASL_LEVEL_ERR;
    if ([format rangeOfString:@"[w]"].location != NSNotFound) return ASL_LEVEL_WARNING;
    if ([format rangeOfString:@"[n]"].location != NSNotFound) return ASL_LEVEL_NOTICE;
    if ([format rangeOfString:@"[i]"].location != NSNotFound) return ASL_LEVEL_INFO;
    if ([format rangeOfString:@"[d]"].location != NSNotFound) return ASL_LEVEL_DEBUG;
    
    return ASL_LEVEL_DEBUG; // if not specified return the lowest log level - DEBUG
}

NSString * _formatWithoutVisualLogLevelPrefix(NSString *format)
{
    NSString * unprefixedFormat = format;
    NSUInteger loc = [format rangeOfString:@"]"].location;
    if (loc != NSNotFound) {
        unprefixedFormat = [format substringFromIndex:loc+1];
    }
    
    NSMutableCharacterSet * whitespaceSet = [NSMutableCharacterSet whitespaceCharacterSet];
    loc = [unprefixedFormat rangeOfCharacterFromSet:[whitespaceSet invertedSet]].location;

    if (loc == NSNotFound) return unprefixedFormat;
    
    return [unprefixedFormat substringFromIndex:loc];
}
