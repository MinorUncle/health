//
//  MedicineCollectController.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/25.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "FoodCollectController.h"
#import "FoodTool.h"
#import "FoodCell.h"
#import "DetailFoodController.h"
@interface FoodCollectController ()
{
}
@end

@implementation FoodCollectController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setTitle:@"收藏"];
    [self getData];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
    [self.tableView reloadData];
}
-(void)getData
{
    NSMutableArray* arry;
    arry = [FoodTool getFoodArryWithCoding];
    _food = arry;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _food==nil?0:_food.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListMedicine"];
    if (cell == nil) {
        cell = [[FoodCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListMedicine"];
    }
    
    cell.foodModel = _food[indexPath.row];
    cell.row = indexPath.row;
    
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodCell* cell =  (FoodCell*)[tableView cellForRowAtIndexPath:indexPath];
//    cell.topImageView.image = [UIImage imageNamed:@"cellHeader_highlighted.png"];
    
    DetailFoodController* controller = [[DetailFoodController alloc]init];
    controller.food = cell.foodModel;
    [self.navigationController pushViewController:controller animated:YES];
    
//    cell.topImageView.image = [UIImage imageNamed:@"cellHeader.png"];
    
       return indexPath;
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [FoodTool deleteFood:_food[indexPath.row]];
        [_food removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
