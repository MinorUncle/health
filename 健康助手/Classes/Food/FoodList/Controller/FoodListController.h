//
//  MedicineController.h
//  健康助手
//
//  Created by 未成年大叔 on 15/7/23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
@class NSDictionary;


@interface FoodListController : UITableViewController <MJRefreshBaseViewDelegate,UITextFieldDelegate>
@property (nonatomic,assign)int ID;
@property (nonatomic,assign)int currentPage;
@property(nonatomic,strong)NSMutableArray* food;

@end
