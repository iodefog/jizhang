//
//  SSJReportFormsPercentCircleAdditionView.h
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJPercentCircleAdditionNodeItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJPercentCircleAdditionNode : UIView

@property (nonatomic, readonly, strong) SSJPercentCircleAdditionNodeItem *item;

- (nullable instancetype)initWithItem:(SSJPercentCircleAdditionNodeItem *)item;

- (BOOL)testOverlap:(SSJPercentCircleAdditionNode *)view;

- (void)beginDrawWithCompletion:(void (^)(void))completion;
    
@end

NS_ASSUME_NONNULL_END