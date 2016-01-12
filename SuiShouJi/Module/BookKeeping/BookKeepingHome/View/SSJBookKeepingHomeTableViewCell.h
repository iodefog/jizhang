//
//  SSJBookKeepingHomeTableViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJBookKeepHomeItem.h"

@interface SSJBookKeepingHomeTableViewCell : SSJBaseTableViewCell
@property (nonatomic,strong) SSJBookKeepHomeItem *item;

typedef void(^beginEditeBtnClickBlock)(SSJBookKeepingHomeTableViewCell *cell);

@property (nonatomic, copy) beginEditeBtnClickBlock beginEditeBtnClickBlock;

typedef void(^editeBtnClickBlock)(SSJBookKeepingHomeTableViewCell *cell);

@property (nonatomic, copy) editeBtnClickBlock editeBtnClickBlock;


typedef void(^deleteButtonClickBlock)();

@property (nonatomic, copy) deleteButtonClickBlock deleteButtonClickBlock;

@property (nonatomic) BOOL isEdite;
@end
