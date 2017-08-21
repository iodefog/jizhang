//
//  SSJFinancingItemProtocol.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSJFinancingItemProtocol

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

@end
