//
//  SSJRecycleRecoverClearCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJRecycleRecoverClearCellItem.h"

@interface SSJRecycleRecoverClearCell : SSJBaseTableViewCell

@property (nonatomic, copy) void(^recoverBtnDidClick)(SSJRecycleRecoverClearCell *cell);

@property (nonatomic, copy) void(^deleteBtnDidClick)(SSJRecycleRecoverClearCell *cell);

@end
