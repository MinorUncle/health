//
//  MedicineBaseController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/8/12.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "MediclineBaseController.h"
#import "MedicineCell.h"
#import "MedicineTool.h"
#import "DetailMedicineController.h"
#import "MJRefresh.h"
#import "UIImage+MJ.h"
@interface MedicineBaseController ()<MJRefreshBaseViewDelegate>
{

}
@end

@implementation MedicineBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MedicineTool initOffsetNumber];    //初始化变量
    //初始化变量
    self.findState = NO;
    if(self.ID == 0)[self getData];
    
    [self addRefreshViews];

}
-(void)getData
{
    self.medicine = [[NSMutableArray alloc]init];
    self.currentPage =1;

    [MedicineTool ListWithParam:@{@"id":@(self.ID),@"page":@(self.currentPage)} success:^(NSArray *mesicines) {
        self.currentPage ++;
        [self.medicine addObjectsFromArray:mesicines];
        [self.tableView reloadData];
    } failure:^(NSError *err) {
        MyLog(@"err---%@",err);
    }];
    
}

-(void)buildUI
{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kTableBorderWidth, 0);
    self.view.backgroundColor = kGlobalBg;
}

- (void)addRefreshViews
{
    
    // 2.上拉加载更多
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.medicine==nil?0:self.medicine.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MedicineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"List"];
    if (cell == nil) {
        cell = [[MedicineCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"List"];
    }
    
    cell.medicine = self.medicine[indexPath.row];
    cell.row = indexPath.row;
    
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MedicineCell* cell =  (MedicineCell*)[tableView cellForRowAtIndexPath:indexPath];
    //    cell.topImageView.image = [UIImage imageNamed:@"cellHeader_highlighted.png"];
    
    DetailMedicineController* controller = [[DetailMedicineController alloc]initWithID:cell.medicine.ID];
    if (self.Navigationdelegate == nil) {
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [self.Navigationdelegate pushViewController:controller animated:YES];
    }
    //    cell.topImageView.image = [UIImage imageNamed:@"cellHeader.png"];
    
    return indexPath;
    
}


- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if(!self.findState)
    {
        [MedicineTool ListWithParam:@{(self.idKey == nil?@"id":self.idKey):@(self.ID),@"page":@(self.currentPage)} success:^(NSArray *Medicine) {
            
            [self.medicine addObjectsFromArray:Medicine];
            [self.tableView reloadData];
            [refreshView endRefreshing];
            [self showNewStatusCount:Medicine.count];
            self.currentPage++;
            
        } failure:^(NSError *err) {
            MyLog(@"err---%@",err);
            [refreshView endRefreshing];
            
        }];
    }else{
        
        [MedicineTool SerachWithParam:@{@"keyword":self.keyWord,@"page":@(self.currentPage)} success:^(NSArray *Medicine) {
            [self.medicine addObjectsFromArray:Medicine];
            [self.tableView reloadData];
            
            [refreshView endRefreshing];
            self.currentPage++;
        } failure:^(NSError *err) {
            MyLog(@"%@",err);
            [refreshView endRefreshing];
        }];
        
    }
}

#pragma mark 展示最新数据的数目
- (void)showNewStatusCount:(int)count
{
    // 1.创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.enabled = NO;
    btn.adjustsImageWhenDisabled = NO;
    
    [btn setBackgroundImage:[UIImage resizedImage:@"timeline_new_status_background.png"] forState:UIControlStateNormal];
    CGFloat w = self.view.frame.size.width;
    CGFloat h = 35;
    btn.frame = CGRectMake(0, kStatusDockHeight, w, h);
    NSString *title = count?[NSString stringWithFormat:@"共有%d条新数据", count]:@"所有数据加载完毕";
    [btn setTitle:title forState:UIControlStateNormal];
    [self.navigationController.view insertSubview:btn belowSubview:self.navigationController.navigationBar];
    
    // 2.开始执行动画
    CGFloat duration = 0.5;
    
    [UIView animateWithDuration:duration animations:^{ // 下来
        btn.transform = CGAffineTransformMakeTranslation(0, h);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^{// 上去
            btn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [btn removeFromSuperview];
        }];
    }];
}


@end
