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

//  Based on http://doing-it-wrong.mikeweller.com/2012/07/youre-doing-it-wrong-1-nslogdebug-ios.html
//  https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/chapters/LoggingErrorsAndWarnings.html

static void AddStderrOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asl_add_log_file(NULL, STDERR_FILENO);  // we need to add the stderr as an output of the asl facility in order to see DEBUG logs in debuger
    });
}

void _TFLog(int level, const char * file, int line, NSString *format, ...)
{
    AddStderrOnce();
    
    va_list argumentList;
    va_start(argumentList, format);

    NSString * path = [NSString stringWithUTF8String:file];
    NSString * message = [[NSString alloc] initWithFormat:format
                                                arguments:argumentList];
    NSString * str = [NSString stringWithFormat:@"%@:%d - %@",[path lastPathComponent], line, message];
    
    asl_log(NULL, NULL, level, "%s", [str UTF8String]);
    
    va_end(argumentList);
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