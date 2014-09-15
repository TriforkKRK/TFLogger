//
//  TFAppDelegate.m
//  TFLogger
//
//  Created by CocoaPods on 09/11/2014.
//  Copyright (c) 2014 Krzysztof Profic. All rights reserved.
//

#import "TFAppDelegate.h"
#import <TFLogger/TFLogger.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

//#define NSLog(...) NSLogToTFLoggerAdapter(__VA_ARGS__)

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation TFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    
//    DDLogError(@"dd error");
 
//    TFAddLoggerClousure(ASLClousure(), 1);
    
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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
