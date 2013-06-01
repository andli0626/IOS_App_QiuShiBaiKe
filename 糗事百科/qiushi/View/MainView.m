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
    UIButton *topButton;//顶部按钮
    UIImageView *topImage;//顶部按钮中的图片
}

@end

@implementation MainView
@synthesize mContentView;
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
    
    //微软雅黑 20号
    UIFont *font = [UIFont fontWithName:MENUFONT_FAMILY size:MENUFONT_SIZE];
    
    //初始化自定义菜单
    [DIYMenu setDelegate:self];
    
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
    
    
    
    topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [topButton setFrame:CGRectMake(0, 0, 200, 35)];
    [topButton setTag:kTagMenu];
    [topButton setTintColor:[UIColor whiteColor]];
    topButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [topButton setTitle:@"随便逛逛" forState:UIControlStateNormal];
    
    [topButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    topImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_att_input_pressed.png"]];
    [topImage setCenter:CGPointMake(155, 16)];
    [topButton addSubview:topImage];
    
    
    //如果是首页,就设置导航的titleView为topButton,其他页面就是空
    if (_typeQiuShi == QiuShiTypeTop) {
        self.navigationItem.titleView = topButton;
    }else
        self.navigationItem.titleView = nil;
    
    
    
    //设置背景颜色
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    
    //初始化数据库
    [SqliteUtil initDb];
    
    //每隔一段时间，提示用户去评分
    [self pingFen];
    
    //添加内容的TableView
    self.mContentView = [[ContentView alloc]initWithNibName:@"ContentView" bundle:nil];
    [mContentView.view setFrame:CGRectMake(0, 0, kDeviceWidth, self.view.frame.size.height)];
    //加载数据  typeQiuShi=1001 timeType=1
    [mContentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
    [self.view addSubview:mContentView.view];
        
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
//    DLog("viewDidAppear");
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated
{
//    DLog("viewWillDisappear");
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
//    DLog("viewWillAppear");
    [super viewWillAppear:animated];
}


#pragma mark - action

#pragma mark 按钮点击事件
- (void)btnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    switch ([btn tag])
    {
        //顶部按钮点击
        case kTagMenu:
        {
            [DIYMenu show];//显示自定义菜单
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
        self.navigationItem.titleView = topButton;
    }else
        self.navigationItem.titleView = nil;
    //刷新 数据
    [mContentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
}

/*****************DIYMenu相关方法*****************/
#pragma mark - DIYMenuDelegate

//菜单选中
- (void)menuItemSelected:(NSString *)action
{
    NSLog(@"您选中了:%@", action);
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
    
    [topButton setTitle:action forState:UIControlStateNormal];
    [mContentView LoadPageOfQiushiType:_typeQiuShi Time:_timeType];
}

- (void)menuActivated
{
    NSLog(@"DIYMenu激活");
}

- (void)menuCancelled
{
    NSLog(@"DIYMenu取消");
}
/*****************DIYMenu相关方法*****************/


#ifdef _FOR_DEBUG_
-(BOOL) respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}
#endif


@end
