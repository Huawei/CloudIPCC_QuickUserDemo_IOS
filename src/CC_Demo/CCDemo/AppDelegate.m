//
//  AppDelegate.m
//  CCDemo
//
//  Created by mwx325691 on 16/3/31.
//  Copyright © 2016年 mwx325691. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"

#import "tup_def.h"
#import "call_interface.h"
#import "tup_conf_baseapi.h"
#import "tup_conf_extendapi.h"
#import "tup_conf_otherapi.h"

//Class CCImpHander;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:kSCREEN];
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSString *sdkVersion = [[CCUtil shareInstance] getVersion];
    NSLog(@"sdk version:%@",sdkVersion);
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [path stringByAppendingPathComponent:@"TUP_LOG"];
    NSLog(@"path = %@",path);
    [[CCUtil shareInstance] setLogPath:logPath level:LOG_DEBUG];
 
    [[CCUtil shareInstance] initSDK];
    
    [self initDataConferenceServices];
    
    LoginViewController *loginCtrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginCtrl];
    self.window.rootViewController = navCtrl;
    
//    MainViewController *vc = [[MainViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = nav;
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        
        if (granted) {
            
            // 用户同意获取麦克风
            
        } else {
            
            // 用户不同意获取麦克风
            
        }
        
    }];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initDataConferenceServices { Init_param initParam;
    initParam.os_type = CONF_OS_IOS;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) { initParam.dev_type = CONF_DEV_PHONE; }
    else
    { initParam.dev_type = CONF_DEV_PAD; }
    initParam.dev_dpi_x = 0; initParam.dev_dpi_y = 0; initParam.media_log_level = LOG_DEBUG; initParam.sdk_log_level = LOG_DEBUG; initParam.conf_mode = 0;
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingString:@"/TUPC60log/dataConf"];
    strncpy(initParam.log_path, [path UTF8String], TC_MAX_PATH); strncpy(initParam.temp_path, [path UTF8String], TC_MAX_PATH); tup_conf_init(false, &initParam);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CCUtil shareInstance] unInitSDK];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

