//
//  MedicineTool.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//
// 文件路径
#define kFile [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"CollectFood.data"]


#import "FoodTool.h"
#import "bHttpTool.h"
#import "HomeBaseTool.h"
#import "Food.h"
#import "Healthcfg.h"
#import "FoodSQLiteManager.h"
#import "ConnentTool.h"
@interface FoodTool()

@end
@implementation FoodTool
static NSInteger _offlineListNumber;//离线状态下列表的总数据;用于防止重复浏览
static NSInteger _offlineSerachNumber;//离线状态下查询的总数据;用于防止重复浏览
static NSInteger _offlineClassNumber;//离线状态下分类的总数据;用于防止重复浏览



+(void)initPath
{
    [self initWithList:foodList class:foodClass search:foodSerach detail:foodDetail dataFile:foodDataFile appkey:foodAppKey];
}
+ (NSMutableArray*)getFoodArryWithCoding
{
    NSMutableArray* arry = [[NSMutableArray alloc]init];
    [arry addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:kFile]];
    return arry;
}

+ (void)saveFood:(Food*)food
{
    NSMutableArray* arry = [[NSMutableArray alloc]init];
    [arry addObjectsFromArray:[self getFoodArryWithCoding]];
    BOOL flg = NO;
    for (Food* i in arry) {
        if(i.ID == food.ID)flg = YES;
    }
    if(!flg)[arry addObject:food];
    
    [NSKeyedArchiver archiveRootObject:arry toFile:kFile];
}
+(void)deleteFood:(Food*)food{
    NSMutableArray* arry = [[NSMutableArray alloc]init];
    [arry addObjectsFromArray:[self getFoodArryWithCoding]];
    for (Food* i in arry) {
        if(i.ID == food.ID)
        {
            [arry removeObject:i];
            break;
        }
    }
    
    [NSKeyedArchiver archiveRootObject:arry toFile:kFile];
    
}


+(id)getData:(id)dic
{
    return [[Food alloc]initWithDict:dic];
}
+(id)getTypeData:(id)dic
{
    return [[Food alloc] initWithDict:dic];
}


//#program mark 数据库
+ (void)ListWithParam:(NSDictionary*)param success:(Success)success failure:(Failure)failure
{
    NSArray* arry;
    //离线状态
    if ([[ConnentTool sharedConnentTool] mainScanType] == kscanTypeWithoutNet) {
    
        arry = [[FoodSQLiteManager sharedFoodSQLiteManager] queryFoodWithFilter:nil limit:20 offset:_offlineListNumber];
        _offlineListNumber +=arry.count;
        success(arry);
        return;
    }
    
    //正常状态,获得数据后存储
   

    [super ListWithParam:param success:^(NSArray* obj){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (Food* i in obj) {
                [[FoodSQLiteManager sharedFoodSQLiteManager]addFood:i];
            }
        });
        
        success(obj);
    }  failure:failure];
//    [super ListWithParam:param success:success failure:failure]

}
+ (void)SerachWithParam:(NSDictionary*)param  success:(Success)success failure:(Failure)failure
{
    
    //离线状态
    if ([[ConnentTool sharedConnentTool] mainScanType] == kscanTypeWithoutNet) {
        NSArray* arry;
        
        //查询关键字
        NSString* keyWord = [param objectForKey:@"keyword"];
        NSString* filter = [NSString stringWithFormat:@" name LIKE  '%%%@' or bar LIKE '%%%@' or tag LIKE '%%%@' ",keyWord,keyWord,keyWord];
        arry = [[FoodSQLiteManager sharedFoodSQLiteManager] queryFoodWithFilter:filter limit:20 offset:_offlineSerachNumber];
        _offlineSerachNumber += arry.count;
        success(arry);
        return;
    }
    
    //正常状态,获得数据后存储
    [super SerachWithParam:param success:^(NSArray* obj){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (Food* i in obj) {
                [[FoodSQLiteManager sharedFoodSQLiteManager]addFood:i];
            }
        });
       
        success(obj);
    }failure:failure];
}
+ (void)DetailWithParam:(NSDictionary*)param  success:(DetailSuccess)success failure:(DetailFailure)failure
{
    //离线状态
    if ([[ConnentTool sharedConnentTool] mainScanType] == kscanTypeWithoutNet) {
        Food* arry;
        NSInteger ID = [[param objectForKey:@"id"] integerValue];
        arry = [[FoodSQLiteManager sharedFoodSQLiteManager] queryFoodWithFoodID:ID];
        success(arry);
        return;
    }
    
    //正常状态,获得数据后存储
    [super DetailWithParam:param success:^( Food* obj){
        __block Food* blockObj = obj;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString* filter = [NSString stringWithFormat:@" id = %d and detailMessage != '(null)' ",obj.ID];
            //判断是否存在详细内容在数据库;
            NSArray* foods = [[FoodSQLiteManager sharedFoodSQLiteManager]queryFoodWithFilter:filter];
            if (foods.count == 0) {
                Food* food = [[FoodSQLiteManager sharedFoodSQLiteManager]queryFoodWithFoodID:obj.ID];
                blockObj = [self combineFoodWithSoc:obj desc:food];
                [[FoodSQLiteManager sharedFoodSQLiteManager]removeFood:obj.ID];
                [[FoodSQLiteManager sharedFoodSQLiteManager]addFood:blockObj];
            }
        });
       
        success(obj);
    }failure:failure];
}
//+ (void)TypeWithParam:(NSDictionary*)param  success:(TypeSuccess)success failure:(TypeFailure)failure
//{
//    //离线状态
//    if ([[ConnentTool sharedConnentTool] mainScanType] == kscanTypeWithoutNet) {
//                NSArray* arry;
//        
//        //查询关键字
//        NSString* keyWord = [param objectForKey:@"keyword"];
//        NSString* filter = [NSString stringWithFormat:@" name LIKE  '%%%@' or bar LIKE '%%%@' or tag LIKE '%%%@' ",keyWord,keyWord,keyWord];
//        arry = [[FoodSQLiteManager sharedFoodSQLiteManager] queryFoodWithFilter:filter limit:20 offset:_offlineClassNumber];
//        _offlineClassNumber += arry.count;
//        success(arry);
//        return;
//    }
//    
//    //正常状态,获得数据后存储
//    [super TypeWithParam:param success:^(NSArray* obj){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            for (Food* i in obj) {
//                [[FoodSQLiteManager sharedFoodSQLiteManager]addFood:i];
//            }
//        });
//        success(obj);
//    }failure:failure];
//
//}
+(Food* )combineFoodWithSoc:(Food*)soc desc:(Food*)desc
{
    //[@"id",@"name",@"scanTimes",@"tag",@"detailMessage",@"image",@"food",@"bar"];
    if (soc.tag == nil)soc.tag = desc.tag;
    if (soc.detailMessage == nil)soc.detailMessage = desc.detailMessage;
    if (soc.image == nil)soc.image = desc.image;
    if (soc.food == nil)soc.food = desc.food;
    if (soc.bar == nil)soc.bar = desc.bar;
    return soc;
}

@end
