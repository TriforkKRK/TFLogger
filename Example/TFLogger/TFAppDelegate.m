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

#import "TFAppDelegate.h"
#import <TFLogger/TFLogger+NSLogVisualFormat.h>
#import <TFLogger/TFLoggerHandlerToCocoaLumberjackAdapter.h>

#define NSLog(...) NSLogToTFLoggerAdapter(@"TFLoggerNSLog", __VA_ARGS__)

static const int ddLogLevel = LOG_LEVEL_DEBUG;

@implementation TFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    TFLoggerSetBaselineLevel(ASL_LEVEL_DEBUG);
#endif
    
    TFLoggerAddLogHandler(TFASLLogHandler);
    TFLoggerSetDefaultModuleName(@"TFLoggerExamp");
    
//
//    CocoaLumberjackAdapter:
//    To enable CocoaLumberjack integration just uncomment the following 4 lines:
//
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    TFLoggerRemoveAllHandlers();
//    TFLoggerAddHandler(CocoaLumberjackToTFLoggerHandlerAdapter);
//    DDLogDebug(@"aaaa ddlog debug");
//
    
    TFLogEmergency(@"emergency");
    TFLogAlert(@"alert");
    TFLogCritical(@"critical");
    TFLogError(@"error");
    TFLogWarning(@"warning");
    TFLogNotice(@"notice");
    TFLogInfo(@"info");
    TFLogDebug(@"debug");
    
    NSLog(@"[d]   nslog"); // on a device log it is "error"
    
    // Override point for customization after application launch.
    return YES;
}

@end
