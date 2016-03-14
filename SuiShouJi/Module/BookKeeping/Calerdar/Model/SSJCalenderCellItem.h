//
//  SSJCalenderCellItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJCalenderCellItem : SSJBaseItem
@property (nonatomic,strong) NSString *backGroundColor;
@property (nonatomic,strong) NSString *titleColor;
@property (nonatomic,strong) NSString *dateStr;
@property (nonatomic) BOOL isSelectable;
@end
