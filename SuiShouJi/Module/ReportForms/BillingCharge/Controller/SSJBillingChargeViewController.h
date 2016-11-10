//
//  SSJBillingChargeViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  记账流水
#import "SSJBaseViewController.h"

@class SSJDatePeriod;

NS_ASSUME_NONNULL_BEGIN

@interface SSJBillingChargeViewController : SSJBaseViewController

// 收支类型ID或成员ID，必传
@property (nonatomic, copy) NSString *ID;

// 账本id，根据此id展示哪个账本的数据，如果不传就默认展示当前账本的数据，如果传all就展示所有账本数据
@property (nonatomic, copy) NSString *booksId;

// 查询周期内的流水
@property (nonatomic, strong) SSJDatePeriod *period;

// 收支类型的颜色
@property (nonatomic, strong) UIColor *color;

// 是否是成员流水（不是成员流水就是类别流水）
@property (nonatomic) BOOL isMemberCharge;

// 是否是支出流水（只有是成员流水时需要传值）
@property (nonatomic) BOOL isPayment;

@end

NS_ASSUME_NONNULL_END
