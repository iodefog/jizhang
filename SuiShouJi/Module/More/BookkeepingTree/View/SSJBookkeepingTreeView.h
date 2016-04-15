//
//  SSJBookkeepingTreeView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJBookkeepingTreeCheckInModel;

@interface SSJBookkeepingTreeView : UIView

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

- (void)setCheckInModel:(SSJBookkeepingTreeCheckInModel *)model finishLoad:(void(^)())finish;

- (void)startRainning;

@end
