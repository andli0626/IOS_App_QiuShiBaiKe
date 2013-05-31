//
//  LeftController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LeftView.h"
#import "MainView.h"
#import "DDMenuController.h"
#import "AppDelegate.h"
#import "AboutView.h"
#import "SetViewController.h"
#import "PurchaseInView.h"
#import "MyNavigationController.h"
#import "FavouriteView.h"

@interface LeftView ()
{
    UISlider *_mSlider;//伪 调节屏幕亮度
    int _mainType;
}
@property (nonatomic, assign) int mainType;
@end
@implementation LeftView

@synthesize tableView=_tableView;
@synthesize items = _items;
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;
@synthesize setBtn = _setBtn;
@synthesize isNormalTable = _isNormalTable;
@synthesize mainType = _mainType;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _menuController = (DDMenuController*)((AppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
    
    _items = [[NSMutableArray alloc]initWithObjects:@"随便逛逛",@"新鲜出炉",@"有图有真相",@"个人收藏",@"设置",@"关于", nil];
    
    
    
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    _setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_setBtn setBackgroundImage:[UIImage imageNamed:@"settingsIcon.png"] forState:UIControlStateNormal];
    [_setBtn setFrame:CGRectMake(320 - 27 - 70, (44 - 27) *.5, 27, 27)];
    [_setBtn setShowsTouchWhenHighlighted:YES];
    [_setBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setBtn];
    
    
    //调节亮度的 滑动条
    _mSlider = [[UISlider alloc]initWithFrame:CGRectMake(15.0, 12 , 220, 20)];
    [_mSlider setMaximumValue:1.0];
    [_mSlider setMinimumValue:.2];
    [_mSlider setValue:1.0];
    [_mSlider setMaximumValueImage:[UIImage imageNamed:@"set_asc.png"]];
    [_mSlider setMinimumValueImage:[UIImage imageNamed:@"set_desc.png"]];
    [_mSlider addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventValueChanged];
    
    
    self.isNormalTable = YES;
    _mainType = 1001;
    
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
   [delegate.window addSubview:delegate.lightView];
    
    
    
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 480 - 44 -20) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = (id<UITableViewDelegate>)self;
        tableView.dataSource = (id<UITableViewDataSource>)self;
        tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    
    NSIndexPath *index0 = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:index0 animated:YES scrollPosition:UITableViewScrollPositionBottom];
    
    //仿Path菜单
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"story-button.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"story-button-pressed.png"];
    
    // Camera MenuItem.
    QuadCurveMenuItem *cameraMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"story-camera.png"]
                                                         highlightedContentImage:nil];
    // People MenuItem.
    QuadCurveMenuItem *peopleMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[UIImage imageNamed:@"story-people.png"]
                                                         highlightedContentImage:nil];
    // Place MenuItem.
    QuadCurveMenuItem *placeMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"story-place.png"]
                                                        highlightedContentImage:nil];
    // Music MenuItem.
    QuadCurveMenuItem *musicMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"story-music.png"]
                                                        highlightedContentImage:nil];
    // Thought MenuItem.
    QuadCurveMenuItem *thoughtMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                 highlightedImage:storyMenuItemImagePressed
                                                                     ContentImage:[UIImage imageNamed:@"story-thought.png"]
                                                          highlightedContentImage:nil];
    // Sleep MenuItem.
    QuadCurveMenuItem *sleepMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[UIImage imageNamed:@"story-sleep.png"]
                                                        highlightedContentImage:nil];
    
    NSArray *menus = [NSArray arrayWithObjects:cameraMenuItem, peopleMenuItem,placeMenuItem,
                      musicMenuItem, thoughtMenuItem, sleepMenuItem,
                      nil];
    
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];
    menu.delegate = self;
//    [self.view addSubview:menu];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    _items = nil;
}


#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{

    return 4;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isNormalTable == YES) {
        if (section == 0) {
            return self.items.count;
        }else{
            return 0;
        }
    }else{
        if (section == 0) {
            return 1;
        }else{
            return 0;
        }
    }

        

    
    
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
     if (_isNormalTable == YES) {
         if (indexPath.section == 0) {
             cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
         }
         cell.textLabel.font = [UIFont fontWithName:@"微软雅黑" size:15.0];
         [cell.textLabel setTextColor:[UIColor whiteColor]];
          [_mSlider removeFromSuperview];
         
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     }else{
         if (indexPath.section == 0) {
             cell.textLabel.text = @"";

             [_mSlider removeFromSuperview];
             [cell.contentView addSubview:_mSlider];
             cell.accessoryType = UITableViewCellAccessoryNone;
         }

        
     }
    
    
    return cell;
    
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"我的糗事囧事 v1.0.120901";
    }else if(section == 1)
    {
        return @"内容及版权归糗事百科所有";
    }else if(section == 2){
        return @"个人仅作学习之用";
    }else{
        return @"邮箱：ww1095@163.com";
    }
    
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    if (_mainType == (1001 + indexPath.row)) {
        [_menuController showRootController:YES];
    }else if (indexPath.row == 0){
        
        [self.navController popToRootViewControllerAnimated:YES];
        self.mainViewController.title = @"";
        
        self.mainViewController.typeQiuShi = 1001 + indexPath.row ; //
        [self.mainViewController refreshDate];
        [_menuController showRootController:YES];
    }else if (indexPath.row == 1){
        [self.navController popToRootViewControllerAnimated:YES];
        self.mainViewController.title = [NSString stringWithFormat:@"%@", [self.items objectAtIndex:indexPath.row]];
        
        self.mainViewController.typeQiuShi = 1001 + indexPath.row ; //
        [self.mainViewController refreshDate];
        [_menuController showRootController:YES];
    }else if (indexPath.row == 2){
        [self.navController popToRootViewControllerAnimated:YES];
        self.mainViewController.title = [NSString stringWithFormat:@"%@", [self.items objectAtIndex:indexPath.row]];
        
        self.mainViewController.typeQiuShi = 1001 + indexPath.row ; //
        [self.mainViewController refreshDate];
        [_menuController showRootController:YES];
    }else if (indexPath.row == 3){
        FavouriteView *favourite = [[FavouriteView alloc]initWithNibName:@"FavouriteViewController" bundle:nil];
        
        [self.navController pushViewController:favourite animated:YES];
        [_menuController showRootController:YES];

    }else if (indexPath.row == 4){
        SetViewController *set = [[SetViewController alloc]initWithNibName:@"SetViewController" bundle:nil];
        
        [self.navController pushViewController:set animated:YES];
        [_menuController showRootController:YES];
    }else if (indexPath.row == 5){
        AboutView *about = [[AboutView alloc]initWithNibName:@"AboutViewController" bundle:nil];
        [self.navController pushViewController:about animated:YES];
        
        [_menuController showRootController:YES];
    }


    _mainType = 1001 + indexPath.row;
    
    
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Select the index : %d",idx);
    if (idx == 0)
    {
        //程序内购买
//        PurchaseInViewController *purchase = [[PurchaseInViewController alloc]initWithNibName:@"PurchaseInViewController" bundle:nil];
//        [self.navController pushViewController:purchase animated:YES];

        
    }
     [_menuController showRootController:YES];
}



- (void)btnClick:(id)sender
{
//    UIButton *btn = (UIButton* )sender;
    self.isNormalTable = !self.isNormalTable;
    [self.tableView reloadData];
}


- (void)changeAction:(id)sender {
    
    UISlider *mSlider = (UISlider*)sender;

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.lightView setAlpha:(1 - [mSlider value])];
    
    if ([mSlider value] < .5) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
}



#ifdef _FOR_DEBUG_
-(BOOL) respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}
#endif

@end
