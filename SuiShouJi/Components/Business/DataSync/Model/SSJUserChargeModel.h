//
//  SSJUserChargeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  记账流水模型

#import "SSJDataSyncModel.h"

@interface SSJUserChargeModel : SSJDataSyncModel

//  流水编号
@property (nonatomic, copy) NSString *ICHARGEID;

//  金额
@property (nonatomic, copy) NSString *IMONEY;

//  收支类型ID
@property (nonatomic, copy) NSString *IBILLID;

//  资金账户类型ID
@property (nonatomic, copy) NSString *IFID;

//  日期
@property (nonatomic, copy) NSString *CADDDATE;

//  变化前余额
@property (nonatomic, copy) NSString *IOLDMONEY;

//  当前余额
@property (nonatomic, copy) NSString *IBALANCE;

//  账单日期
@property (nonatomic, copy) NSString *CBILLDATE;

@end
