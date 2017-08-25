//
//  SSJRecycleRecoverClearCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJRecycleRecoverClearCell : SSJBaseTableViewCell

@property (nonatomic, copy) void(^recoverBtnDidClick)(SSJRecycleRecoverClearCell *cell);

@property (nonatomic, copy) void(^deleteBtnDidClick)(SSJRecycleRecoverClearCell *cell);

@end

@interface SSJRecycleRecoverClearCellItem : SSJBaseCellItem

@property (nonatomic) BOOL recoverBtnLoading;

@property (nonatomic) BOOL clearBtnLoading;

@property (nonatomic, copy) NSString *recycleID;

@end
