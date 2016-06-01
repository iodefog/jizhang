//
//  SSJFundingTransferDetailItem.h
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFundingTransferDetailItem : NSObject

//转账金额
@property(nonatomic, strong) NSString *transferMoney;

//转账时间
@property(nonatomic, strong) NSString *transferDate;

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

@end
