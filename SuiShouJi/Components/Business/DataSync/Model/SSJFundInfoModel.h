//
//  SSJFundInfoModel.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  资金帐户模型

#import "SSJDataSyncModel.h"

@interface SSJFundInfoModel : SSJDataSyncModel

//  账户ID
@property (nonatomic, copy) NSString *CFUNDID;

//  账户名称
@property (nonatomic, copy) NSString *CACCTNAME;

//  图标
@property (nonatomic, copy) NSString *CICOIN;

//  父账户ID(若为一级账户则父账户记为 root)
@property (nonatomic, copy) NSString *CPARENT;

//  颜色编号
@property (nonatomic, copy) NSString *CCOLOR;

//  添加时间
@property (nonatomic, copy) NSString *CADDDATE;

//  ？？？
@property (nonatomic, copy) NSString *CMEMO;

@end
