//
//  ClassifyController.h
//  健康助手
//
//  Created by 未成年大叔 on 15/7/24.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "classifyBox.h"
#import "MJRefresh.h"
@interface CheckClassifyController : UIViewController <ClassifyDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,copy)NSArray* checkClass;
@property(nonatomic,assign)int ID; ///是分类id
@end
