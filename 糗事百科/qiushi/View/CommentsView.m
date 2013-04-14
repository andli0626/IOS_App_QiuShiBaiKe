//
//  CommentsViewController.m
//  NetDemo
//
//  Created by Michael on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentsView.h"

#import "CJSONDeserializer.h"
#import "QiuShi.h"
#import "DDMenuController.h"
#import "SHSShareViewController.h"
#import "SqliteUtil.h"
#import "iToast.h"

#define FShareBtn       101
#define FBackBtn        102
#define FAddComments    103

@interface CommentsView () <ASIHTTPRequestDelegate,
UITableViewDataSource,
UITableViewDelegate
>
-(void) GetErr:(ASIHTTPRequest *)request;
-(void) GetResult:(ASIHTTPRequest *)request;
-(void) btnClicked:(id)sender;
- (void)loadData;
@property (nonatomic) BOOL refreshing;
@end

@implementation CommentsView
@synthesize refreshing = _refreshing;
@synthesize asiRequest = _asiRequest;
@synthesize list;
@synthesize qs;
@synthesize tableView,commentView;
@synthesize shareView = _shareView;




-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"精彩评论";
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    
    NSError *error;
    if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
                                         action:@"CommentsView"
                                          label:@"Example iOS"
                                          value:99
                                      withError:&error]) {
        NSLog(@"error in trackEvent");
    }
    
    
    //    NSLog(@"viewDidLoad comments");
    
    //是否显示广告
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if ([[ud objectForKey:@"showAD"] boolValue] == YES) {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                self.view.frame.size.height -GAD_SIZE_320x50.height - 44,
                                                GAD_SIZE_320x50.width,
                                                GAD_SIZE_320x50.height)];//设置位置
        
        
        bannerView_.adUnitID = MY_BANNER_UNIT_ID;//调用你的id
        bannerView_.rootViewController = self;
        [self.view addSubview:bannerView_];//添加bannerview到你的试图
        [bannerView_ loadRequest:[GADRequest request]];
    }
    
    
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]]];
    list = [[NSMutableArray alloc]init];
    
    
    
    
    //    UIImage* image= [UIImage imageNamed:@"comm_btn_top_n.png"];
    //    UIImage* imagef= [UIImage imageNamed:@"comm_btn_top_s.png"];
    //    CGRect frame_1= CGRectMake(0, 0, image.size.width, image.size.height);
    //    UIButton* backButton= [[UIButton alloc] initWithFrame:frame_1];
    //    [backButton setBackgroundImage:image forState:UIControlStateNormal];
    //    [backButton setBackgroundImage:imagef forState:UIControlStateHighlighted];
    //    [backButton setTitle:@"分享" forState:UIControlStateNormal];
    //    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [backButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    //定制自己的风格的  UIBarButtonItem
    //    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //
    //
    //    [self.navigationItem setRightBarButtonItem:someBarButtonItem];
    
    
    
    //糗事列表
    tableView = [[UITableView alloc]  initWithFrame:CGRectMake(0, 0, kDeviceWidth, [self getTheHeight]-60)];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.scrollEnabled = NO;
    [commentView addSubview:tableView];
    
    //是否显示广告
    if ([[ud objectForKey:@"showAD"] boolValue] == YES) {
        //评论列表
        commentView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight-60-5-GAD_SIZE_320x50.height)];
    }else{
        //评论列表
        commentView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight-60-5)];
    }
    
    commentView.backgroundColor = [UIColor clearColor];
    commentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    commentView.dataSource = self;
    commentView.delegate = self;
    commentView.scrollEnabled = YES;
    [self.view addSubview:commentView];
    commentView.tableHeaderView = tableView;
    _asiRequest = nil;
    
    //添加footimage
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    UIImage *footbg= [UIImage imageNamed:@"block_center_background.png"];
    UIImageView *footbgView = [[UIImageView alloc]initWithImage:footbg];
    [footbgView setFrame:CGRectMake(0, 0, 320, 25)];
    [footView addSubview:footbgView];
    
    
    UIImage *footimage = [UIImage imageNamed:@"block_foot_background.png"];
    UIImageView *footimageView = [[UIImageView alloc]initWithImage:footimage];
    [footimageView setFrame:CGRectMake(0, 25, 320, 15)];
    [footView addSubview:footimageView];
    
    //    //添加评论
    //    UIButton *addcomments = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [addcomments setFrame:CGRectMake(20,2,280,28)];
    //    [addcomments setBackgroundImage:[[UIImage imageNamed:@"button_vote.png"]stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    //    [addcomments setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    //    [addcomments.titleLabel setFont: [UIFont fontWithName:@"微软雅黑" size:14]];
    //    [addcomments setTitle:@"点击发表评论" forState:UIControlStateNormal];
    //    [addcomments addTarget:self action:@selector(BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [addcomments setTag:FAddComments];
    //    [footView addSubview:addcomments];
    
    commentView.tableFooterView = footView;
    [commentView addSubview:footView];
    
    
    [self loadData];
    
    [self registerGesture];
}


-(void)registerGesture{
    
    UISwipeGestureRecognizer *swipeRcognize1=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRcognize1.delegate=self;
    [swipeRcognize1 setEnabled:YES];
    [swipeRcognize1 delaysTouchesEnded];
    [swipeRcognize1 cancelsTouchesInView];
    swipeRcognize1.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRcognize1];
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    UISwipeGestureRecognizerDirection direction = recognizer.direction;
    if (direction == 1)
    {
        //右
        [self backMainContent];
        
        
    }else if (direction == 2)
    {
        
        //左
        
    }
    
}



-(void) btnClicked:(id)sender
{
    
    _shareView = [[SHSShareViewController alloc]initWithRootViewController:self];
    [_shareView.view setFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    _shareView.sharedtitle = @"糗事百科-生活百态尽在Qiushibaike...";
    _shareView.sharedText = qs.content;
    _shareView.sharedURL =@"http://www.qiushibaike.com";
    _shareView.sharedImageURL = qs.imageURL;
    [_shareView showShareKitView];
    //    [self.view addSubview:_shareView.view];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addSubview:_shareView.view];
    
}


- (void)favoriteAction:(id)sender
{
    
    [SqliteUtil updateDataIsFavourite:qs.qiushiID isFavourite:@"yes"];
    
    [[iToast makeText:@"已添加到收藏..."] show];
}

- (void)viewDidUnload
{
    
    _shareView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    //解决本view与root 共同的手势 冲突
    _menuController = (DDMenuController*)((AppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
    [_menuController.tap setEnabled:NO];
    [_menuController.pan setEnabled:NO];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [_menuController.tap setEnabled:YES];
    [_menuController.pan setEnabled:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Your actions

- (void)loadData{
    [list removeAllObjects];
    NSURL *url = [NSURL URLWithString:CommentsURLString(qs.qiushiID)];
    _asiRequest = [ASIHTTPRequest requestWithURL:url];
    [_asiRequest setDelegate:self];
    [_asiRequest setDidFinishSelector:@selector(GetResult:)];
    [_asiRequest setDidFailSelector:@selector(GetErr:)];
    [_asiRequest startAsynchronous];
    
    
}

-(void) GetErr:(ASIHTTPRequest *)request
{
    
}

-(void) GetResult:(ASIHTTPRequest *)request
{
    NSData *data =[request responseData];
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
    if ([dictionary objectForKey:@"items"]) {
        NSArray *array = [NSArray arrayWithArray:[dictionary objectForKey:@"items"]];
        for (NSDictionary *qiushi in array) {
            Comments *cm = [[Comments alloc]initWithDictionary:qiushi];
            [list addObject:cm];
        }
    }
    [commentView reloadData];
}
#pragma mark - TableView*

- (NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section{
    if (tableview == tableView) {
        return 1;
    }else {
        return [list count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableview == tableView) {
        
        static NSString *identifier = @"_QiShiCELL";
        ContentCell *cell =(ContentCell *) [tableview dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            //设置cell 样式
            cell = [[ContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.txtContent.NumberOfLines = qs.content.length * 14 * 0.05 + 1;
        }
        
        //设置内容
        cell.txtContent.text = qs.content;
        //发布时间
        cell.txtTime.text = qs.fbTime;
        //设置图片
        if (qs.imageURL!=nil && qs.imageURL!= @"") {
            cell.imgUrl = qs.imageURL;
            cell.imgMidUrl = qs.imageMidURL;
            //  cell.imgPhoto.hidden = NO;
        }else
        {
            cell.imgUrl = @"";
            cell.imgMidUrl = @"";
            //  cell.imgPhoto.hidden = YES;
        }
        //设置用户名
        if (qs.anchor!=nil && qs.anchor!= @"")
        {
            cell.txtAnchor.text = qs.anchor;
        }else
        {
            cell.txtAnchor.text = @"匿名";
        }
        //设置标签
        if (qs.tag!=nil && qs.tag!= @"")
        {
            cell.txtTag.text = qs.tag;
        }else
        {
            cell.txtTag.text = @"";
        }
        //设置up ，down and commits
        [cell.goodbtn setTitle:[NSString stringWithFormat:@"%d",qs.upCount] forState:UIControlStateNormal];
        [cell.goodbtn setEnabled:NO];
        [cell.badbtn setTitle:[NSString stringWithFormat:@"%d",qs.downCount] forState:UIControlStateNormal];
        [cell.badbtn setEnabled:NO];
        [cell.commentsbtn setTitle:[NSString stringWithFormat:@"%d",qs.commentsCount] forState:UIControlStateNormal];
        [cell.commentsbtn setEnabled:NO];
        
        
        [cell.saveBtn addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //自适应函数
        [cell resizeTheHeight:kTypeContent];
        return cell;
    }else {
        static NSString *identifier1 = @"_CommentCell";
        CommentsCell *cell =(CommentsCell *) [tableview dequeueReusableCellWithIdentifier:identifier1];
        if (cell == nil){
            //设置cell 样式
            cell = [[CommentsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.txtContent.NumberOfLines = 0;
        }
        Comments *cm = [list objectAtIndex:indexPath.row];
        //设置内容
        cell.txtContent.text = cm.content;
        
        //        int i = [cm.content intValue];
        ////        NSLog(@"%d",i);
        //
        //        if (i > 0 ) {
        //            NSRange range1 = [cm.content rangeOfString:[NSString stringWithFormat:@"%d楼",i]];
        //            NSRange range2 = [cm.content rangeOfString:[NSString stringWithFormat:@"%dl",i]];
        //            NSRange range3 = [cm.content rangeOfString:[NSString stringWithFormat:@"%dL",i]];
        //
        //
        //
        //
        //            if (range1.length > 0) {
        //                NSLog(@"Range is: %@", NSStringFromRange(range1));
        //                NSLog (@" shortname: %@", [cm.content substringWithRange:range1]);
        ////                NSLog(@"==%@",range1.location);
        ////                cell.textLabel.textColor
        //            }else if (range2.length > 0) {
        //                 NSLog(@"Range is: %@", NSStringFromRange(range2));
        //                 NSLog (@" shortname: %@", [cm.content substringWithRange:range2]);
        //            }else if (range3.length > 0) {
        //                 NSLog(@"Range is: %@", NSStringFromRange(range3));
        //                 NSLog (@" shortname: %@", [cm.content substringWithRange:range3]);
        //            }else{//只有数字
        ////                 NSLog(@"没有");
        //            }
        //        }
        
        
        cell.txtfloor.text = [NSString stringWithFormat:@"%d",cm.floor];
        //设置用户名
        if (cm.anchor!=nil && cm.anchor!= @"")
        {
            cell.txtAnchor.text = cm.anchor;
        }else
        {
            cell.txtAnchor.text = @"匿名";
        }
        //自适应函数
        [cell resizeTheHeight];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableview heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == tableview) {
        CGFloat height = [self getTheHeight];
        [tableView setFrame:CGRectMake(0, 0, kDeviceWidth, height)];
        return  height;
    }else {
        return [self getTheCellHeight:indexPath.row];
    }
    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(CGFloat) getTheHeight
{
    CGFloat contentWidth = 280;
    // 设置字体
    UIFont *font = [UIFont fontWithName:@"微软雅黑" size:14];
    // 显示的内容
    NSString *content = qs.content;
    // 计算出长宽
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, (content.length * 14 * 0.05 + 1 ) * 14) lineBreakMode:UILineBreakModeTailTruncation];
    CGFloat height;
    if (qs.imageURL==nil || [qs.imageURL isEqualToString:@""]) {
        height = size.height+214;
    }else
    {
        height = size.height+294;
    }
    // 返回需要的高度
    return height;
}

-(CGFloat) getTheCellHeight:(int) row
{
    CGFloat contentWidth = 280;
    // 设置字体
    UIFont *font = [UIFont fontWithName:@"微软雅黑" size:14];
    
    Comments *cm = [self.list objectAtIndex:row];
    // 显示的内容
    NSString *content = cm.content;
    // 计算出长宽
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 220) lineBreakMode:UILineBreakModeTailTruncation];
    CGFloat height = size.height+30;
    // 返回需要的高度
    return height;
}




- (void)backMainContent
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    //    NSLog(@"dealloc comments");
    self.asiRequest.delegate = nil;
}

#ifdef _FOR_DEBUG_
-(BOOL) respondsToSelector:(SEL)aSelector {
    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];
}
#endif
@end