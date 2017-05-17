//
//  SSJCalenderCellItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJCalenderCellItem : SSJBaseCellItem
//日历背景色
@property (nonatomic,strong) NSString *backGroundColor;

//日历字体颜色
@property (nonatomic,strong) NSString *titleColor;

//日历的日期
@property (nonatomic,strong) NSString *dateStr;

//当前日期是否能被选中
@property (nonatomic) BOOL isSelectable;

//当前日期有没有数据
@property (nonatomic) BOOL haveDataOrNot;

//当前日期有没有数据
@property (nonatomic) double backGroundAlpha;

@end
