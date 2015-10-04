//
//  MedicineCell.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//
#define MedicIMGH 160
#define MedicIMGW 220
#define MedicCellH 40   //图片占用高度
#define MedicCellW 40   //图片占用宽度
#import "bHttpTool.h"
#import "UIImage+MJ.h"
#import "HomeBaseCell.h"
#import "homeBaseModel.h"
#import "Healthcfg.h"
@interface HomeBaseCell ()
{

}
@end
@implementation HomeBaseCell
@synthesize imageView = _imageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 1.添加本身的子控件
        [self addAllSubviews];
        
        
        // 2.设置背景
        [self setBg];
    }
    return self;
}

#pragma mark 设置背景
- (void)setBg
{
    
    [self.contentView setContentMode:UIViewContentModeCenter];

    // 1.默认背景
    _bg.image = [UIImage resizedImage:@"common_card_middle_background.png"];
    
    
    // 2.长按背景
    _selectedBg.image= [UIImage resizedImage:@"common_card_middle_background_highlighted.png"];
    [self setBackgroundColor:[UIColor clearColor]];
}


#pragma mark 添加本身的子控件
- (void)addAllSubviews
{
       // 1.配图
    _imageView = [[UIImageView alloc]init];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    CGRect rect = CGRectMake(2, 2, MedicCellW, MedicCellH);
    
    //绘制圆角
    [_imageView.layer setCornerRadius:MedicCellH/2];
    [_imageView.layer setMasksToBounds:YES];
    
    [_imageView clearsContextBeforeDrawing];
    [_imageView setFrame:rect];


    [self.contentView addSubview:_imageView];
    

    
    
    //名称
    _name = [[UILabel alloc]init];
    rect = (CGRect){CGRectGetMaxX(_imageView.frame)+10,rect.origin.y,self.bounds.size.width - _imageView.frame.size.width,_imageView.frame.size.height * 0.5};
    [_name setFrame:rect];
    
    [self.contentView addSubview:_name];

    //左边小标题
   _leftTitle = [[UILabel alloc]init];
    [_leftTitle setTextColor:[UIColor redColor]];
    [_leftTitle setFont:[UIFont systemFontOfSize:12]];
    rect = (CGRect){CGRectGetMaxX(_imageView.frame)+10,CGRectGetMaxY(rect),80,_imageView.frame.size.height * 0.5};
    [_leftTitle setFrame:rect];
    
    [self.contentView addSubview:_leftTitle];
    
    //右边小标题
    _rightTitle = [[UILabel alloc]init];
    [_rightTitle setTextColor:[UIColor redColor]];
    [_rightTitle setFont:[UIFont systemFontOfSize:10]];
    rect = (CGRect){CGRectGetMaxX(rect)+10,rect.origin.y,self.bounds.size.width - CGRectGetMaxX(rect),rect.size.height};
    [_rightTitle setFrame:rect];
    
    [self.contentView addSubview:_rightTitle];
    
   }


-(void)setRow:(int)row{
    _row = row;
    if (row == 0) {
        _bg.image = [UIImage resizedImage:@"common_card_top_background.png"];
        _selectedBg.image =[UIImage resizedImage:@"common_card_top_background_highlighted.png"];
    }else
    {
        _bg.image = [UIImage resizedImage:@"common_card_middle_background.png"];
        _selectedBg.image =[UIImage resizedImage:@"common_card_mieddle_background_highlighted.png"];
    }
}




@end
