//
//  MainViewController.h
//  NetDemo
//
//  Created by xyxd  on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AudioToolbox/AudioToolbox.h>

@class ContentView;
#import "DIYMenu.h"


@interface MainView : UIViewController<UIAlertViewDelegate,DIYMenuDelegate>
{
    ContentView *m_contentView;  //内容页面

    int _typeQiuShi;
    int _timeType;
    
    UIBarButtonItem* _timeItem;
    
    
    SystemSoundID soundID;
}

@property (nonatomic,retain) ContentView *m_contentView;
@property (nonatomic,assign) int typeQiuShi;


@property (nonatomic, retain) UISegmentedControl *timeSegment;
@property (nonatomic, retain) UIBarButtonItem *timeItem;

- (void)refreshDate;
@end
