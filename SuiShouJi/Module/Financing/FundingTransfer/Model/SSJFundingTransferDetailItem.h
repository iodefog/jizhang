//
//  SSJFundingTransferDetailItem.h
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFundingTransferDetailItem : NSObject

// 周期转账id
@property (nonatomic, strong) NSString *ID;

//转账金额
@property(nonatomic, strong) NSString *transferMoney;

//转账时间
@property(nonatomic, strong) NSString *transferDate;

// 周期转账起始时间
@property(nonatomic, strong) NSString *beginDate;

// 周期转账结束时间
@property(nonatomic, strong) NSString *endDate;

//转入账户的id
@property(nonatomic, strong) NSString *transferInId;

//转出账户的id
@property(nonatomic, strong) NSString *transferOutId;

//转入账户名称
@property(nonatomic, strong) NSString *transferInName;

//转出账户名称
@property(nonatomic, strong) NSString *transferOutName;

//转入账户图标
@property(nonatomic, strong) NSString *transferInImage;

//转出账户图标
@property(nonatomic, strong) NSString *transferOutImage;

//转账的备注
@property(nonatomic, strong) NSString *transferMemo;

//转入的流水id
@property(nonatomic, strong) NSString *transferInChargeId;

//转出的流水id
@property(nonatomic, strong) NSString *transferOutChargeId;

//转入账户的操作类型
@property(nonatomic) NSInteger transferInFundOperatorType;

//转出账户的操作类型
@property(nonatomic) NSInteger transferOutFundOperatorType;

//是否可编辑
@property(nonatomic) BOOL editable;

// 是否开启
@property (nonatomic) BOOL opened;

// 周期转账循环类型
@property (nonatomic) SSJCyclePeriodType cycleType;

@end
