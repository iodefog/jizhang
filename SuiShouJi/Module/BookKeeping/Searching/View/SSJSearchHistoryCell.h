//
//  SSJSearchHistoryCell.h
//  SuiShouJi
//
//  Created by ricky on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJSearchHistoryItem.h"

@interface SSJSearchHistoryCell : SSJBaseTableViewCell

@property (nonatomic, copy) void (^deleteAction)(SSJSearchHistoryItem *item);

@end
