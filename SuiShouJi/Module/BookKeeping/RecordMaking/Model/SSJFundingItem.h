//
//  SSJFundingItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFundingItem : NSObject

//账户ID
@property (nonatomic,strong) NSString *fundingID;

//账户名称
@property (nonatomic,strong) NSString *fundingName;

//账户颜色
@property (nonatomic,strong) NSString *fundingColor;

//账户图标
@property (nonatomic,strong) NSString *fundingIcon;

//账户父类型
@property (nonatomic,strong) NSString *fundingParent;

//账户余额
@property (nonatomic) double fundingBalance;

//账户备注
@property (nonatomic,strong) NSString *fundingMemo;

@end
