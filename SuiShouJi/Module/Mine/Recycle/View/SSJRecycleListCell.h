//
//  SSJRecycleListCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJRecycleListCellItem.h"

@interface SSJRecycleListCell : SSJBaseTableViewCell

@property (nonatomic, copy) void(^expandBtnDidClick)(SSJRecycleListCell *cell);

@end
