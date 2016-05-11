//
//  SSJFinancingHomeitem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFinancingHomeitem : NSObject

//账户名称
@property (nonatomic,strong) NSString *fundingName;

//账户颜色
@property (nonatomic,strong) NSString *fundingColor;

//账户ID
@property (nonatomic,strong) NSString *fundingID;

//账户图标
@property (nonatomic,strong) NSString *fundingIcon;

//账户父类
@property (nonatomic,strong) NSString *fundingParent;

//账户余额
@property (nonatomic) double fundingAmount;

//是否是添加按钮
@property (nonatomic) BOOL isAddOrNot;


//账户备注
@property(nonatomic,strong) NSString *fundingMemo;


@property(nonatomic) NSInteger fundingOrder;
@end
