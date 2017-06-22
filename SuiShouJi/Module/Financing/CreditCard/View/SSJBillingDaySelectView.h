//
//  SSJBillingDaySelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/8/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBillingDaySelectView : UIView

typedef NS_ENUM(NSInteger, SSJDateSelectViewType) {
    SSJDateSelectViewTypeFullMonth,      
    SSJDateSelectViewTypeShortMonth,
    SSJDateSelectViewTypeAlipay
};

// 选择日期类型,1是31天,0是28天
@property(nonatomic) SSJDateSelectViewType type;

@property(nonatomic) NSInteger currentDate;

@property (nonatomic, copy) void (^dateSetBlock)(NSInteger selectedDay);

- (instancetype)initWithFrame:(CGRect)frame Type:(SSJDateSelectViewType)type;

- (void)show;

- (void)dismiss;

@end
