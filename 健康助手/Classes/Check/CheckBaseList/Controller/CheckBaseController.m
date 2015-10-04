//
//  CheckBaseController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/8/12.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "CheckBaseController.h"
#import "CheckCell.h"
#import "CheckTool.h"
#import "DetailCheckController.h"
#import "MJRefresh.h"
#import "UIImage+MJ.h"
@interface CheckBaseController ()<MJRefreshBaseViewDelegate>
{

}
@end

@implementation CheckBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CheckTool initOffsetNumber];
    self.check = [[NSMutableArray alloc]init];
    
    //初始化变量
    //初始化变量
    self.currentPage =1;
    self.findState = NO;
    if(self.ID == 0)[self getData];
    
    [self addRefreshViews];
   
}
-(void)getData
{
    self.currentPage =1;

    self.check = [[NSMutableArray alloc]init];
    
    [CheckTool ListWithParam:@{@"id":@(self.ID),@"page":@(self.currentPage)} success:^(NSArray *checks) {
        self.currentPage ++;
        [self.check addObjectsFromArray:checks];
        
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
    
    return self.check==nil?0:self.check.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckCell *cell = [tableView dequeueReusableCellWithIdentifier:@"List"];
    if (cell == nil) {
        cell = [[CheckCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"List"];
    }
    
    cell.checkModel = self.check[indexPath.row];
    cell.row = indexPath.row;
    
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CheckCell* cell =  (CheckCell*)[tableView cellForRowAtIndexPath:indexPath];
    //    cell.topImageView.image = [UIImage imageNamed:@"cellHeader_highlighted.png"];
    
    DetailCheckController* controller = [[DetailCheckController alloc]initWithID:cell.checkModel.ID];
    
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
        [CheckTool ListWithParam:@{(self.idKey == nil?@"id":self.idKey):@(self.ID),@"page":@(self.currentPage)} success:^(NSArray *check) {
            
            [self.check addObjectsFromArray:check];
            [self.tableView reloadData];
            [refreshView endRefreshing];
            [self showNewStatusCount:check.count];
            self.currentPage++;
            
        } failure:^(NSError *err) {
            MyLog(@"err---%@",err);
            [refreshView endRefreshing];
            
        }];
    }else{
        
        [CheckTool SerachWithParam:@{@"keyword":self.keyWord,@"page":@(self.currentPage)} success:^(NSArray *check) {
            [self.check addObjectsFromArray:check];
            [self.tableView reloadData];
            [self showNewStatusCount:check.count];
            [refreshView endRefreshing];
            self.currentPage++;
        } failure:^(NSError *err) {
            MyLog(@"err %@",err);
            [refreshView endRefreshing];
        }];
        
    }}

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
