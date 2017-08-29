//
//  SSJRecycleRecoverClearCellItem.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJRecycleCellItem.h"

@interface SSJRecycleRecoverClearCellItem : SSJBaseCellItem <SSJRecycleCellItem, NSCopying>

@property (nonatomic) BOOL recoverBtnLoading;

@property (nonatomic) BOOL clearBtnLoading;

@end
