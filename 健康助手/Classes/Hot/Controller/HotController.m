//
//  HotController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/8/10.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "HotController.h"
#import "HotDetailHeader.h"
#import "tableScrollView.h"
#import "MedicineTool.h"
#import "FoodTool.h"
#import "CheckTool.h"
#import "DiseaseTool.h"
#import "Medicine.h"
#import "Food.h"
#import "Disease.h"
#import "Check.h"
#import "BaseList.h"
#import "BannerView.h"
#define TOP_Y 64
#define BUTTON_Y 170
#define DETAIL_H 70
typedef void (^dataSuccess)(NSMutableArray* data);
@interface HotController ()<HotDetailHeaderDelegate,tableScrollViewDelegate>
{
    BannerView* _banner;
    
    BOOL isTopDirection;
    NSMutableArray* _currentArry;
}
@property(nonatomic,strong)NSMutableArray* disease;
@property(nonatomic,strong)NSMutableArray* check;
@property(nonatomic,strong)NSMutableArray* food;
@property(nonatomic,strong)NSMutableArray* medicine;


@property (nonatomic,strong)tableScrollView* tableView;
@property (nonatomic,strong)HotDetailHeader* hotDetail;

@end

@implementation HotController

- (void)viewDidLoad {
    [super viewDidLoad];
   [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self buildBanner];
    [self buildHotDedtailHeder];
    [self bulidTable];
    
    [self HotDetailHeader:_hotDetail btnClick:kHotDetailHeaderBtnTypeMedic];//首先点击药品大全
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)freshDataWithType:(HotDetailHeaderBtnType)type success:(dataSuccess) success
{
    switch (type) {
        case kHotDetailHeaderBtnTypeCheck:
        {
            if(self.check == nil){
                [CheckTool TypeWithParam:@{@"id":@(0)} success:^(NSArray *mesicines) {
                    NSMutableArray* arry = [NSMutableArray arrayWithArray:mesicines];
                    self.check = [[NSMutableArray alloc]init];
                   
                    for (Check* i in arry) {
                        NSDictionary* dic = @{@"name":i.name,@"ID":@(i.ID)};
                        [self.check addObject:dic];
                    }
                    
                    _currentArry = self.check;
                    success(_currentArry);

                } failure:^(NSError *err) {
                    MyLog(@"%@",err);
                    
                }];
            }
            else{
                _currentArry = self.check;
                success(_currentArry);
            }
            break;
        }
        case kHotDetailHeaderBtnTypeDisease:
        {
            if(self.disease == nil){
                [DiseaseTool TypeWithParam:@{@"id":@(0)} success:^(NSArray *disease) {
                    NSMutableArray* arry = [NSMutableArray arrayWithArray:disease];
                    self.disease = [[NSMutableArray alloc]init];
                    
                    for (Disease* i in arry) {
                        NSDictionary* dic = @{@"name":i.name,@"ID":@(i.ID)};
                        [self.disease addObject:dic];
                    }
                    
                    _currentArry = self.disease;
                    success(_currentArry);

                } failure:^(NSError *err) {
                    MyLog(@"%@",err);
                }];
            }else{
                _currentArry = self.disease;
                success(_currentArry);
            }
            
            break;
        }
        case kHotDetailHeaderBtnTypeFood:
            
            break;
        case kHotDetailHeaderBtnTypeMedic:
        {
            if(self.medicine == nil)
            {
                [MedicineTool TypeWithParam:@{@"id":@(0)} success:^(NSArray *mesicines) {
                    NSMutableArray* arry = [NSMutableArray arrayWithArray:mesicines];
                    self.medicine = [[NSMutableArray alloc]init];
                    
                    for (Medicine* i in arry) {
                        NSDictionary* dic = @{@"name":i.name,@"ID":@(i.ID)};
                        [self.medicine addObject:dic];
                    }
                    
                    _currentArry = self.medicine;
                    success(_currentArry);
                } failure:^(NSError *err) {
                    MyLog(@"%@",err);
                }];

            }else{
                _currentArry = self.medicine;
                success(_currentArry);
            }
            break;
        }
        default:
            break;
    }
}
-(void)buildBanner
{
    _banner = [[BannerView alloc]init];
    [_banner setBackgroundColor:[UIColor redColor]];
    CGRect rect = CGRectMake(0, kStatusHight, self.view.bounds.size.width, BUTTON_Y - TOP_Y);
    [_banner setFrame:rect];
    [self.view addSubview:_banner];
     
}
-(void)buildHotDedtailHeder
{
    _hotDetail = [HotDetailHeader header];
    CGRect rect = CGRectMake(0.0,BUTTON_Y, self.view.bounds.size.width, DETAIL_H);
    _hotDetail.frame = rect;
    //hotDetail中 slidebar移动的回调函数
    [_hotDetail slideBarItemSelectedCallback:^(NSUInteger idx) {
        [self.tableView moveToIndex:idx];
    }];
    _hotDetail.delegate = self;
    [self.view addSubview:_hotDetail];

}

-(void)bulidTable
{
    CGRect rect = _hotDetail.frame;
    rect.origin.y = CGRectGetMaxY(rect);
    rect.size.height = self.view.bounds.size.height - rect.origin.y -2 ;
    rect.size.width = self.view.bounds.size.width;
    // The frame of tableView, be care the width and height property
//    CGRect frame = CGRectMake(0, bannerH, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.slideBar.frame) , CGRectGetWidth(self.view.frame));
    self.tableView = [[tableScrollView alloc] initWithFrame:rect];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    
    self.tableView.tableScrollViewdelegate = self;
    
}



-(void)dragView:(UIView *)view toViewPoint:(CGPoint)point
{
    CGPoint p = _tableView.center;
    p.x += point.x;
    p.y += point.y;
    
    _tableView.center = p;
    
}
//detailDelegate
/**
 *  结束拖动,根据位置和拖动方向让控件归位
 *
 *  @param view  拖动的控件

 */
-(void)endPanWithView:(UIView *)view
{
    CGRect rect1 = _hotDetail.frame;
    CGRect rect2 = _tableView.frame;
    if (isTopDirection) {
        rect1.origin.y = TOP_Y;
        rect2.origin.y = CGRectGetMaxY(rect1);
        rect2.size.height = self.view.bounds.size.height - rect2.origin.y;

        [UIView animateWithDuration:0.2 animations:^{
            [_hotDetail setFrame:rect1];
            [_tableView setFrame:rect2];
        }];
    } else {
        rect1.origin.y = BUTTON_Y;
        rect2.origin.y = CGRectGetMaxY(rect1);
        rect2.size.height = self.view.bounds.size.height - rect2.origin.y;

        [UIView animateWithDuration:0.2 animations:^{
            [_hotDetail setFrame:rect1];
            [_tableView setFrame:rect2];
        }];
    }

}
/**
 *  根据偏移量offset移动view,并且记录方向
 *
 *  @param view  拖动的控件
 *  @param heigh 偏移量
 */
-(void)panWithView:(UIView *)view offset:(float)heigh
{
    CGRect rect1 = _hotDetail.frame;
    CGRect rect2 = _tableView.frame;
    
    if (heigh > 0) {
        isTopDirection = NO;
        rect1.origin.y += heigh;
        if (rect1.origin.y < BUTTON_Y) {
             _hotDetail.frame = rect1;
            
            rect2.origin.y = CGRectGetMaxY(rect1);
            rect2.size.height = self.view.bounds.size.height - rect2.origin.y;
            _tableView.frame = rect2;
           
        }
    }else{
        isTopDirection = YES;
        rect1.origin.y += heigh;
        if (rect1.origin.y  > TOP_Y ) {
            _hotDetail.frame = rect1;
            
            rect2.origin.y = CGRectGetMaxY(rect1);
            rect2.size.height = self.view.bounds.size.height - rect2.origin.y;
            _tableView.frame = rect2;

        }
    }
    
    
    
}
-(void)HotDetailHeader:(HotDetailHeader *)header btnClick:(HotDetailHeaderBtnType)index
{
   [self freshDataWithType:index success:^(NSMutableArray *data) {
       
       //更新数据
       [self.hotDetail setDataArry:data];

       
       
       //将hotdetail中的btn类型装换为tablescroll中的类型
       TableScrollViewType type;
       switch (index) {
           case kHotDetailHeaderBtnTypeCheck:
               type = kTableScrollViewTypeCheck;
               break;
           case kHotDetailHeaderBtnTypeDisease:
               type = kTableScrollViewTypeDisease;
               break;
           case kHotDetailHeaderBtnTypeFood:
               type = kTableScrollViewTypeFood;
               break;
           case kHotDetailHeaderBtnTypeMedic:
               type = kTableScrollViewTypeMedic;
               break;
               
           default:
               break;
       }
       [self.tableView setDataArry:data Type:type];
       
       
   }];

}


//tablescrollview代理,移动到了index
-(void)tableScrollView:(tableScrollView *)table moveReach:(NSInteger)index
{
    [self.hotDetail selectSlideBarItemAtIndex:index];
}
@end

