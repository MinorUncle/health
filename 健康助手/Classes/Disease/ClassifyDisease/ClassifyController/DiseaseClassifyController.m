//
//  ClassifyController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/24.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "DiseaseClassifyController.h"
#import "classifyBox.h"
#import "DiseaseTool.h"
#import "DiseaseListController.h"
#import "Disease.h"
@interface DiseaseClassifyController ()
{
    ClassifyBox* _box;
}
@end

@implementation DiseaseClassifyController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"分类";
    self.edgesForExtendedLayout = UIRectEdgeNone;
     [self.view setBackgroundColor:[UIColor whiteColor]];
    [self getData:_ID];
    [self addRefreshViews];
    // Do any additional setup after loading the view.
}
- (void)addRefreshViews
{
    // 2.上拉加载更多
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _box;
    footer.delegate = self;
}
#pragma mark 刷新代理方法
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    
        
   
    [DiseaseTool TypeWithParam:@{@"id":@(_ID)} success:^(NSArray *disease) {
        _DiseaseClass = disease;
       if(_box != nil) [_box removeFromSuperview];
        [self buildUI];
        
        [refreshView endRefreshing];

    } failure:^(NSError *err) {
        MyLog(@"%@",err);
        [refreshView endRefreshing];

    }];

    
    
    
    
    
}
-(void)getData:(int)flg
{
    [DiseaseTool TypeWithParam:@{@"id":@(flg)} success:^(NSArray *disease) {
        _DiseaseClass = disease;
        [self buildUI];
    } failure:^(NSError *err) {
        MyLog(@"%@",err);
    }];
}
-(void)buildUI
{
    NSMutableArray* arry = [[NSMutableArray alloc]init];
    for (Disease *i in _DiseaseClass) {
        NSDictionary* dic = @{@"id":@(i.ID),@"name":i.name};
        [arry addObject:dic];
    }
    _box = [[ClassifyBox alloc]initWithClassfyList:arry];
    _box.MBdelegate = self;
    CGRect rect = self.view.bounds;
    [_box setFrame:rect];
    [self.view addSubview:_box];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)ClassifyBox:(ClassifyBox *)box btnClick:(int)btnNum
{
  
        DiseaseListController * controller = [[DiseaseListController alloc]init];
        controller.idKey = @"pid";
        controller.ID = btnNum;
        controller.title = @"疾病列表";
    
        [self.navigationController pushViewController:controller animated:YES];
        
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
