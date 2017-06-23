//
//  SSJMineHomeTableViewHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJMineHeaderView.h"
#import "SSJUserItem.h"
#import "SSJBookkeepingTreeHelper.h"


@interface SSJMineHomeTableViewHeader : UIView

//+ (id)MineHomeHeader;

@property(nonatomic, strong) SSJUserItem *item;

@property(nonatomic) SSJBookkeepingTreeLevel checkInLevel;
 
//点击同步的回调
@property (nonatomic, copy) BOOL (^shouldSyncBlock)();

//点击同步的回调
typedef void (^checkInButtonClickBlock)();

/**
 签名
 */
- (void)setSignStr;

@property (nonatomic, copy) checkInButtonClickBlock checkInButtonClickBlock;

//点击登录回调
typedef void (^HeaderClickedBlock)();

@property (nonatomic, copy) HeaderClickedBlock HeaderClickedBlock;

- (void)updateAfterThemeChange;
@end
