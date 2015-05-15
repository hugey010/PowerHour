//
//  HUAppDelegate.m
//  PowerHour
//
//  Created by Hugey on 12/10/13.
//  Copyright (c) 2013 Hugey. All rights reserved.
//

#import "HUAppDelegate.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "HUPlayerTableViewController.h"

@interface HUAppDelegate()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation HUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PowerHour" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    
    // disable locking the screen
    application.idleTimerDisabled = YES;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([HUPlayerTableViewController isCurrentlyPlaying]) {
        @weakify(self)
        self.bgTask = [application beginBackgroundTaskWithName:@"Skip Songs" expirationHandler:^{
            @strongify(self)
            
            @weakify(self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([HUPlayerTableViewController timeLeftForCurrentSong] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"nextSong" object:nil];
               
                // TODO: use song count from controller static methods
                for (NSInteger i = 1; i <= 10; i++) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([HUPlayerTableViewController songInterval] * i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"nextSong" object:nil];
                        
                        if (i == 10) {
                            [application endBackgroundTask:self.bgTask];
                            self.bgTask = UIBackgroundTaskInvalid;
                        }
                    });
                }
                
                
            });
            
        }];
    }

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
