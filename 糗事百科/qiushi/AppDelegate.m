//
//  AppDelegate.m
//  qiushi
//
//  Created by xyxd mac on 12-8-22.
//  Copyright (c) 2012年 XYXD. All rights reserved.
//

#import "AppDelegate.h"

#import "MainView.h"
#import "DDMenuController.h"

#import "LeftView.h"
#import "CustomNavigationBar.h"
#import "MyNavigationView.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mDDMenuView = _menuController;
@synthesize mainController = mMainView;
@synthesize navController = _navController;
@synthesize leftController = mLeftView;
@synthesize lightView = _lightView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //google analytics
    [[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    NSError *error;
    
    if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                         name:@"iOS1"
                                                        value:@"iv1"
                                                    withError:&error]) {
        NSLog(@"error in setCustomVariableAtIndex");
    }
    
    if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                         action:@"Launch iOS"
                                          label:@"Example iOS"
                                          value:99
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
    
    if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
                                         withError:&error]) {
        NSLog(@"error in trackPageview");
    }
    
    //想摇就写在这～～～
    application.applicationSupportsShakeToEdit=YES;
    
    //默认显示广告
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithBool:YES]  forKey:@"showAD"];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _lightView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [_lightView setUserInteractionEnabled:NO];
    [_lightView setBackgroundColor:[UIColor blackColor]];
    [_lightView setAlpha:.0];
    //    [self.window addSubview:_lightView];
    
    
    mMainView = [[MainView alloc] init];
    
    _navController = [[MyNavigationView alloc] initWithRootViewController:mMainView];
    
    _menuController = [[DDMenuController alloc] initWithRootViewController:_navController];
    
    
    mLeftView = [[LeftView alloc] init];
    mLeftView.navController = _navController;
    mLeftView.mainViewController = mMainView;
    
    _menuController.leftViewController = mLeftView;
        
    self.window.rootViewController = _menuController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    [self.navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_background.png"]];
    
    //判断设备的版本
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
    if ([self.navController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        //ios5 新特性
        [self.navController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_background.png"] forBarMetrics:UIBarMetricsDefault];
        [[NSUserDefaults standardUserDefaults] setObject:@">=5" forKey:@"version"];
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@"<5" forKey:@"version"];
    }
#endif
    
    
    [self.window makeKeyAndVisible];
    return YES;
    
}

- (void)dealloc
{
    [[GANTracker sharedTracker] stopTracker];
}

@end
