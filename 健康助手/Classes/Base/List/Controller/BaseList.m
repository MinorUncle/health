//
//  BaseList.m
//  健康助手
//
//  Created by 未成年大叔 on 15/8/12.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "BaseList.h"
#import "MJRefresh.h"
@interface BaseList ()

@end

@implementation BaseList

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)setID:(int)ID
{
    _ID = ID;
    self.idKey=@"pid";
    [self getData];
    
}
- (UIViewController*)viewController:(UIView*)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
-(void)getData
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
