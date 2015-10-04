//
//  BannerView.m
//  健康助手
//
//  Created by 未成年大叔 on 15/8/14.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "BannerView.h"
#import "MedicineTool.h"
#import "CheckTool.h"
#import "DiseaseTool.h"
#import "FoodTool.h"
#import "Healthcfg.h"
#import "HttpTool.h"
#import "DetailFoodController.h"
#import "DetailDiseaseController.h"
@interface BannerView()
@property(nonatomic,assign)NSInteger medicineID;
@property(nonatomic,assign)NSInteger checkID;
@property(nonatomic,assign)NSInteger diseaseID;
@property(nonatomic,assign)NSInteger foddID;

@property(nonatomic,copy)NSString* medicineImage;
@property(nonatomic,copy)NSString* checkImage;
@property(nonatomic,copy)NSString* diseaseImage;
@property(nonatomic,copy)NSString* foodImage;

@property(nonatomic,retain)UIPageControl* page;
@property(nonatomic,retain)NSMutableArray* dataArry;

@end
@implementation BannerView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.pagingEnabled =YES;
     
        self.dataArry = [[NSMutableArray alloc]init];
        [self getDiseaseWithBlock:^(NSString * image,NSInteger ID) {
            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"DISEASE"};
            [self.dataArry addObject:dic];
        }];
        [self getDiseaseWithBlock:^(NSString * image,NSInteger ID) {
            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"DISEASE"};
            [self.dataArry addObject:dic];
        }];
        [self getDiseaseWithBlock:^(NSString * image,NSInteger ID) {
            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"DISEASE"};
            [self.dataArry addObject:dic];
            [self reloadUI];
        }];
        
////
//        [self getFoodWithBlock:^(NSString * image,NSInteger ID) {
//            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
//            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"FOOD"};
//            [self.dataArry addObject:dic];
//        }];
////
//        [self getFoodWithBlock:^(NSString * image,NSInteger ID) {
//            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
//            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"FOOD"};
//            [self.dataArry addObject:dic];
//        }];
//        
//        [self getFoodWithBlock:^(NSString * image,NSInteger ID) {
//            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
//            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"FOOD"};
//            [self.dataArry addObject:dic];
//        }];
//        
//        [self getFoodWithBlock:^(NSString * image,NSInteger ID) {
//            NSString* imgstr = [imageBaseURL stringByAppendingPathComponent:image];
//            NSDictionary* dic = @{@"image":imgstr,@"id":@(ID),@"type":@"FOOD"};
//            [self.dataArry addObject:dic];
//        }];
      
    }
    return self;
}
-(void)setFrame:(CGRect)frame
{
 
    [super setFrame:frame];

    if (self.dataArry.count > 0) {
        [self startUI];
    }else{
        [self reloadUI];
    }
}
-(void)setContentOffset:(CGPoint)contentOffset
{
    //系统自动调用contentOffset.y == -64,  未知原因
    CGPoint point = contentOffset;
    point.y = 0;
    [super setContentOffset:point];

}
-(void)startUI
{
    UIImage* img = [UIImage imageNamed:@"timeline_image_loading.png"];
    UIImageView* imgView = [[UIImageView alloc]init];
    imgView.frame = self.bounds;
    imgView.image = img;
    [self addSubview:imgView];
}
-(void)reloadUI
{
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
  
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestuer:)];
   
    for (int i=0; i< self.dataArry.count; i++) {
        UIImageView* imgView = [[UIImageView alloc]init];
        NSString* img =self.dataArry[i][@"image"];
        [HttpTool downloadImage:img place:[UIImage imageNamed:@"timeline_image_loading.png"] imageView:imgView];
        CGRect rect = CGRectMake(self.bounds.size.width * i, 0,self.bounds.size.width, self.bounds.size.height);
        [imgView setFrame:rect];
        [imgView addGestureRecognizer:tapGesture];
        [self addSubview:imgView];

    }
    self.contentSize =(CGSize){self.bounds.size.width * self.dataArry.count,0};
    [self reloadPageControl];
}
-(void)tapGestuer:(UITapGestureRecognizer*)tap
{
    int num = self.contentOffset.x / self.bounds.size.width;
    NSInteger ID = [self.dataArry[num][@"id"] integerValue];
    NSString* type = self.dataArry[num][@"type"];
    if ([type isEqualToString:@"FOOD"]){
        DetailFoodController* controller = [[DetailFoodController alloc]initWithID:ID];
        
        [[self viewController:self].navigationController pushViewController:controller animated:YES];
    } else if ([type isEqualToString:@"DISEASE"]){
        DetailDiseaseController* controller = [[DetailDiseaseController alloc]initWithID:ID];
        
        [[self viewController:self].navigationController pushViewController:controller animated:YES];
    }
}
- (void)reloadPageControl
{
    [_page removeFromSuperview];
    CGSize size = self.frame.size;
    UIPageControl *page = [[UIPageControl alloc] init];
    page.center = CGPointMake(size.width * 0.5, size.height * 0.95);
    page.numberOfPages = self.dataArry.count;
    page.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"new_feature_pagecontrol_checked_point.png"]];
    page.pageIndicatorTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"new_feature_pagecontrol_point.png"]];
    page.bounds = CGRectMake(0, 0, 150, 0);
    [self addSubview:page];
    _page = page;
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
    
    if(self.checkImage == nil)
    {
    }
    if(self.diseaseImage == nil)
    {
    }
    if(self.foodImage == nil)
    {
    }
}
-(void)getMedicine
{
    if(self.medicineImage == nil)
    {
        NSInteger ID =  arc4random()%1000;
        NSDictionary* pram =@{@"id":@(ID)};
        [MedicineTool DetailWithParam:pram success:^(id mesicines) {
            
            if (((Medicine*)mesicines).image != nil) {
                self.medicineImage = ((Medicine*)mesicines).image;
            }else{
                [self getMedicine];
            }
        } failure:^(NSError *err) {
            NSLog(@"%@",err);
        }];
    }
}
-(void)getCheck
{
    if(self.checkImage == nil)
    {
        NSInteger ID =  arc4random()%1000;
        NSDictionary* pram =@{@"id":@(ID)};
        [CheckTool DetailWithParam:pram success:^(id mesicines) {
            
            if (((Check*)mesicines).image != nil) {
                self.checkImage = ((Check*)mesicines).image;
            }else{
                [self getCheck];
            }
        } failure:^(NSError *err) {
            NSLog(@"%@",err);
        }];
    }
}
-(void)getFoodWithBlock:(void (^)(NSString*,NSInteger))block
{
    
    NSInteger ID =  arc4random()%1000;
    NSDictionary* pram =@{@"id":@(ID)};
    [FoodTool DetailWithParam:pram success:^(id mesicines) {
        
        if (((Food*)mesicines).image != nil && ![((Food*)mesicines).image isEqualToString:foodDefaultImage]) {
            block(((Food*)mesicines).image,ID);
        }else{
            [self getFoodWithBlock:^(NSString *image,NSInteger imgID) {
                block(image,imgID);
                
            }];
        }
    } failure:^(NSError *err) {
        NSLog(@"%@",err);
    }];
    
}
-(void)getDiseaseWithBlock:(void (^)(NSString*,NSInteger))block
{
    if(self.diseaseImage == nil)
    {
        NSInteger ID =  arc4random()%100;
        NSDictionary* pram =@{@"id":@(ID)};
        [DiseaseTool DetailWithParam:pram success:^(id mesicines) {
            
            if (((Disease*)mesicines).image != nil && ![((Disease*)mesicines).image isEqualToString:diseaseDefaultImage]) {
                block(((Disease*)mesicines).image,ID);
            }else{
                [self getDiseaseWithBlock:^(NSString *image,NSInteger imgID) {
                    block(image,imgID);
                    
                }];
            }
        } failure:^(NSError *err) {
            NSLog(@"%@",err);
        }];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _page.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect rect = _page.frame;
    rect.origin.y += scrollView.contentOffset.y;
    _page.frame = rect;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
