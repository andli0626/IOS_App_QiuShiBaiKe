//
//  MainViewController.m
//  NetDemo
//
//  Created by xyxd on 12-8-10.
//  Copyright (c) 2012年 XYXD. All rights reserved.
//

#import "MainView.h"


#import "SqliteUtil.h"


#import "ContentView.h"
#import "SVStatusHUD.h"

#import "DIYMenuOptions.h"


#define kTagMenu      101


//启动一定次数，引导用户去评分
#define kQDCS @"qdcs"  //启动次数
#define kTime 10


@interface MainView ()
{
    UIButton *_segmentButton;//
    UIImageView *_arrowImage;
}

@end

@implementation MainView
@synthesize m_contentView;
@synthesize typeQiuShi = _typeQiuShi;
@synthesize timeSegment = _timeSegment;
@synthesize timeItem = _timeItem;

#pragma mark - view life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIFont *font = [UIFont fontWithName:MENUFONT_FAMILY size:MENUFONT_SIZE];
    [DIYMenu setDelegate:self];
    
    // Add menu items
    [DIYMenu addMenuItem:@"随便逛逛"
                withIcon:[UIImage imageNamed:@"portfolioIcon.png"]
               withColor:[UIColor colorWithRed:0.18f green:0.76f blue:0.93f alpha:1.0f]
                withFont:font];
    [DIYMenu addMenuItem:@"日精选"
                withIcon:[UIImage imageNamed:@"skillsIcon.png"]
               withColor:[UIColor colorWithRed:0.28f green:0.55f blue:0.95f alpha:1.0f]
                withFont:font];
    [DIYMenu addMenuItem:@"周精选"
                withIcon:[UIImage imageNamed:@"exploreIcon.png"]
               withColor:[UIColor colorWithRed:0.47f green:0.24f blue:0.93f alpha:1.0f]
                withFont:font];
    [DIYMenu addMenuItem:@"月精选"
                withIcon:[UIImage imageNamed:@"settingsIcon.png"]
               withColor:[UIColor colorWithRed:0.57f green:0.0f blue:0.85f alpha:1.0f]
                withFont:font];
    
    
    //初始化 摇一摇刷新
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    
    
    
    //设置糗事类型
    if (!_typeQiuShi) {
        _typeQiuShi = QiuShiTypeTop;
    }
    
    //时间类型
    if (!_timeType) {
        _timeType = QiuShiTimeRandom;
    }
    
    
    
    _segmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_segmentButton setFrame:CGRectMake(0, 0, 200, 35)];
    [_segmentButton setTag:kTagMenu];
    [_segmentButton setTintColor:[UIColor whiteColor]];
    _segmentButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [_segmentButton setTitle:@"随便逛逛" forState:UIControlStateNormal];
    
    [_segmentButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _arrowImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_att_input_pressed.png"]];
    [_arrowImage setCenter:CGPointMake(155, 16)];
    [_segmentButton addSubview:_arrowImage];
    
    if (_typeQiuShi == QiuShiTypeTop) {
        self.navigationItem.titleView = _segmentButton;
    }else
        self.navigationItem.titleView = nil;
    
    
    
    //设置背景颜色
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    
    
    
    [SqliteUtil initDb];
    
    
    
    //每隔一段时间，提示用户去评分
    [self pingFen];
    
    
    //添加内容的TableView
    self.m_contentView = [[ContentView alloc]initWithNibName:@"ContentView" bundle:nil];
    [m_contentView.view setFrame:CGRectMake(0, 0, kDeviceWidth, self.view.frame.size.height)];
    //加载数据  typeQiuShi=1001 timeType=1
    [m_contentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
    [self.view addSubview:m_contentView.view];
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


//摇一摇 的准备
-(BOOL)canBecomeFirstResponder{
    return YES;
}
-(void)viewDidAppear:(BOOL)animated
{
    DLog("viewDidAppear");
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated
{
    DLog("viewWillDisappear");
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog("viewWillAppear");
    [super viewWillAppear:animated];
}


#pragma mark - action


- (void)btnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch ([btn tag])
    {
        case kTagMenu:
        {
            [DIYMenu show];
        }break;
            
            
    }
}

#pragma mark -  引导用户去 评分
- (void) pingFen
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int sum = [[ud objectForKey:kQDCS] intValue];
    
    if (sum < kTime) {
        sum++;
        
    }else if(sum == kTime){
        sum = 0;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"糗事囧事有什么需要改进的吗？去评个分吧~~" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去评分", nil];
        
        [alert show];
        
    }
    
    [ud setInteger:sum forKey:kQDCS];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        //前去评分
        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",MyAppleID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}



//摇动后
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
    DLog(@"UIEventSubType : %d",motion);
    if(motion==UIEventSubtypeMotionShake)
    {
        
        AudioServicesPlaySystemSound (soundID);
        
        [SVStatusHUD showWithImage:[UIImage imageNamed:@"icon_shake.png"] status:@"摇动刷新哦，亲~~"];
        //刷新 数据
        [self refreshDate];
        
    }
    
}

#pragma mark - 刷新数据
- (void)refreshDate
{
    
    if (_typeQiuShi == QiuShiTypeTop) {
        self.navigationItem.titleView = _segmentButton;
    }else
        self.navigationItem.titleView = nil;
    //刷新 数据
    [m_contentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
}


#pragma mark - DIYMenuDelegate

- (void)menuItemSelected:(NSString *)action
{
    NSLog(@"Delegate: selected: %@", action);
    if ([action isEqualToString:@"随便逛逛"]) {
        if (_timeType != QiuShiTimeRandom) {
            _timeType = QiuShiTimeRandom;
        }else{
            return;
        }
        
        
    }else if ([action isEqualToString:@"日精选"]) {
        
        if (_timeType != QiuShiTimeDay) {
            _timeType = QiuShiTimeDay;
        }else{
            return;
        }
        
    }else if ([action isEqualToString:@"周精选"]) {
        
        if (_timeType != QiuShiTimeWeek) {
            _timeType = QiuShiTimeWeek;
        }else{
            return;
        }
        
    }else if ([action isEqualToString:@"月精选"]) {
        
        if (_timeType != QiuShiTimeMonth) {
            _timeType = QiuShiTimeMonth;
        }else{
            return;
        }
        
    }
    
    [_segmentButton setTitle:action forState:UIControlStateNormal];
    [m_contentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
}

- (void)menuActivated
{
    NSLog(@"Delegate: menuActivated");
}

- (void)menuCancelled
{
    NSLog(@"Delegate: menuCancelled");
}


#ifdef _FOR_DEBUG_
-(BOOL) respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}
#endif


@end
