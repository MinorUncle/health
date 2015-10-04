//
//  MedicineController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#define serachH 40
#import "DetailFoodController.h"
#import "FoodListController.h"
#import "bHttpTool.h"
#import "Food.h"
#import "FoodTool.h"
#import "FoodCell.h"
#import "MJRefresh.h"
#import "UIImage+MJ.h"
#import "CircleLoader.h"

@interface FoodListController ()
{
    int _currentPage;
    BOOL _findState; //是否查找状态
    NSString* _keyWord;
}
@end

@implementation FoodListController

- (void)viewDidLoad {
//    self.tableView.delegate = self
    [super viewDidLoad];
//    self.title = @"药物列表";
    self.food = [[NSMutableArray alloc]init];
    _currentPage =1;
    _findState = NO;
    [FoodTool initOffsetNumber];
    [self getData];
    [self buildUI];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self addRefreshViews];

}
-(void)getData
{
   
    [CircleLoader setOnView:self.view withTitle:@"正在努力加载中" animated:YES];
    [FoodTool ListWithParam:@{@"id":@(_ID),@"page":@(_currentPage)} success:^(NSArray *mesicines) {
            _currentPage ++;
            [self.food addObjectsFromArray:mesicines];
    
        [CircleLoader hideFromView:self.view animated:YES];
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
#pragma mark 刷新代理方法
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if(!_findState)
    {
    [FoodTool ListWithParam:@{@"id":@(_ID),@"page":@(_currentPage)} success:^(NSArray *mesicines) {

        [self.food addObjectsFromArray:mesicines];
        [self.tableView reloadData];
        [refreshView endRefreshing];
        [self showNewStatusCount:mesicines.count];
        _currentPage++;

    } failure:^(NSError *err) {
        MyLog(@"err---%@",err);
        [refreshView endRefreshing];

    }];
    }else{
        
        [FoodTool SerachWithParam:@{@"keyword":_keyWord,@"page":@(_currentPage)} success:^(NSArray *mesicines) {
            [self.food addObjectsFromArray:mesicines];
            [self.tableView reloadData];

            [refreshView endRefreshing];
            _currentPage++;
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

-(void)serach:(UITextField*)textField
{
    if ([textField.text isEqualToString:@""])return;
    
    _keyWord = textField.text;
    _findState = YES;
    _currentPage = 1;
    [FoodTool SerachWithParam:@{@"keyword":_keyWord,@"page":@(_currentPage)} success:^(NSArray *mesicines) {
        self.food = [NSMutableArray arrayWithArray:mesicines];
        [self.tableView reloadData];
    } failure:^(NSError *err) {
        MyLog(@"%@",err);
    }];
    
}

#pragma mark - Table view data source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITextField* textView;
    if (section == 0) {
      
        CGRect rect = (CGRect){0,0,self.view.bounds.size.width,serachH};
        textView = [[UITextField alloc]init];
        [textView setFrame:rect];
        UIImage* img = [UIImage resizedImage:@"serach.png"];
        [textView setBackground:img];
        textView.delegate = self;
        
        
        UIImageView* leftImgView = [[UIImageView alloc]init];
        UIImage* leftImg = [UIImage imageNamed:@"search_icon.png"];
        leftImgView.image = leftImg;
        rect.origin = (CGPoint){5,(serachH - leftImg.size.height)/2.0};
        rect.size = leftImg.size;
        [leftImgView setFrame:rect];
        textView.leftView =leftImgView;
        textView.leftViewMode = UITextFieldViewModeAlways;
        textView.clearsOnBeginEditing = NO;
        [textView addTarget:self action:@selector(serach:) forControlEvents:UIControlEventEditingDidEnd];
        
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(serach:) name:UITextFieldTextDidEndEditingNotification object:textView];
        
    }
    return textView;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodCell* cell =  (FoodCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    DetailFoodController* controller = [[DetailFoodController alloc]initWithID:cell.foodModel.ID];
    [self.navigationController pushViewController:controller animated:YES];
    
    //    cell.topImageView.image = [UIImage imageNamed:@"cellHeader.png"];
    
    return indexPath;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _food==nil?0:_food.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListMedicine"];
    if (cell == nil) {
        cell = [[FoodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListMedicine"];
    }
    
    cell.isSerach = _findState;

    cell.foodModel = _food[indexPath.row];

    cell.row = indexPath.row;
    
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
