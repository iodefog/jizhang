//
//  SSJReportFormsPercentCircleAdditionView.h
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJPercentCircleAdditionNodeItem;

@interface SSJPercentCircleAdditionNode : UIView

@property (nonatomic, readonly, strong) SSJPercentCircleAdditionNodeItem *item;

- (instancetype)initWithItem:(SSJPercentCircleAdditionNodeItem *)item;

- (void)beginDrawWithCompletion:(void (^)(void))completion;
    
@end


typedef NS_ENUM(NSInteger, SSJRadianRange) {
    SSJRadianRangeTop,
    SSJRadianRangeRight,
    SSJRadianRangeBottom,
    SSJRadianRangeLeft
};


@interface SSJPercentCircleAdditionNodeItem : NSObject

@property (nonatomic) SSJRadianRange range;

@property (nonatomic) CGPoint startPoint;

@property (nonatomic) CGPoint breakPoint;

@property (nonatomic) CGPoint endPoint;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
