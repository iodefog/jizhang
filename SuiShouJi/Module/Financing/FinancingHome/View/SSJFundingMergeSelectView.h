//
//  SSJFundingMergeSelectView.h
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingHomeitem.h"

@interface SSJFundingMergeSelectView : UIView

@property (nonatomic,strong) SSJFinancingHomeitem *fundingItem;

@property (nonatomic) BOOL selectable;

@property (nonatomic, copy) void(^fundSelectBlock)();

// 类型,1是转入.0是转出
typedef NS_ENUM(NSInteger, SSJFundTransferViewType) {
    SSJFundTransferViewTypeTransferOut = 0,
    SSJFundTransferViewTyperTransferIn = 1
};

@end
