//
//  SSJBookKeepHomeItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBookKeepHomeItem : NSObject

//记账编辑时间
@property (nonatomic,strong) NSString *editeDate;

//记账时间
@property (nonatomic,strong) NSString *billDate;

//记账金额
@property (nonatomic) double chargeMoney;

//记账编号
@property (nonatomic,strong) NSString *chargeID;

//记账类型
@property (nonatomic,strong) NSString *billID;

//账户类型
@property (nonatomic,strong) NSString *fundID;

@end
