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
@property (strong, nonatomic) DDMenuController *menuController;
@property (strong, nonatomic) MainView *mainController;
@property (strong, nonatomic) MyNavigationView *navController;
@property (strong, nonatomic) LeftView *leftController;
@property (strong, nonatomic) UIView *lightView;


@end
