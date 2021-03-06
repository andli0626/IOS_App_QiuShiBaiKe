//
//  SetViewController.h
//  NetDemo
//
//  Created by xyxd mac on 12-8-20.
//
//

#import <UIKit/UIKit.h>

#import "DDMenuController.h"

@interface SetViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
{
    UITableView *mTableView;
    
    NSMutableArray *itemArrays;
    NSMutableArray *subItemArrays;
    UISwitch *adSwitch;
    

}

@property (nonatomic, retain) UITableView *mTable;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *subItems;
@property (nonatomic, retain) UISwitch *adSwitch;


@end

