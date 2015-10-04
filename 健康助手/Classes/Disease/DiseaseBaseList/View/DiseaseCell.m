//
//  MedicineCell.m
//  健康助手
//
//  Created by 未成年大叔 on 15/7/23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//
#define MedicIMGH 160
#define MedicIMGW 220
#define MedicCellH 44   //图片占用高度
#define MedicCellW 44   //图片占用宽度
#import "bHttpTool.h"
#import "UIImage+MJ.h"
#import "DiseaseCell.h"
#import "Disease.h"
#import "Healthcfg.h"
@interface DiseaseCell ()
{

}
@end
@implementation DiseaseCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 1.添加数据本身的子控件
          // 2.添加被转发数据的子控件
        
        // 3.设置背景
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


-(void)setDiseaseModel:(Disease *)diseaseModel
{
    _diseaseModel = diseaseModel;
    // 1.配图

    [bHttpTool downloadImage:[imageBaseURL stringByAppendingPathComponent:_diseaseModel.image] place:[UIImage imageNamed:@"timeline_image_loading.png"] imageView:self.imageView];
    

    if(!self.isSerach)
    {
        //名称
        self.name.text = _diseaseModel.name;
        //类型
        
        self.leftTitle.text = _diseaseModel.place;
        //科室
        self.rightTitle.text = _diseaseModel.department ;
    }else{
        self.name.text = _diseaseModel.title;
        
        self.leftTitle.text = [NSString stringWithFormat:@"搜索次数:%d",_diseaseModel.scanTimes] ;
        
        self.rightTitle.text = _diseaseModel.content ;
        
        
    }
}





@end
