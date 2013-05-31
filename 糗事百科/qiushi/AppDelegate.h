//
//  AppDelegate.h
//  qiushi
//
//  Created by xyxd mac on 12-8-22.
//  Copyright (c) 2012年 XYXD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class MainView;
@class DDMenuController;
@class LeftView;
@class MyNavigationView;

//@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    GADBannerView *bannerView_;//实例变量 bannerView_是一个view
    
    MainView *_mainController;
    MyNavigationView *_navController;
    LeftView *_leftController;
    
    UIView *_lightView;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDMenuController *mMenuView;
@property (strong, nonatomic) MainView *mMainView;
@property (strong, nonatomic) MyNavigationView *mNavigationView;
@property (strong, nonatomic) LeftView *mLeftView;
@property (strong, nonatomic) UIView *lightView;


@end
