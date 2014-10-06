//
//  TFAppDelegate.m
//  TFLogger
//
//  Created by CocoaPods on 09/11/2014.
//  Copyright (c) 2014 Krzysztof Profic. All rights reserved.
//

#import "TFAppDelegate.h"
#import <TFLogger/TFLogger.h>

#define NSLog(...) NSLogToTFLoggerAdapter(@"TFLoggerNSLog", __VA_ARGS__)

@implementation TFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    TFLoggerAddHandler(TFASLLogHandler);
    TFLoggerSetDefaultModuleName(@"TFLoggerExamp");
    TFLoggerSetWhiteListModuleNames(@[@"TFLoggerNSLog", @"TFLoggerExamp"]);
    
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
