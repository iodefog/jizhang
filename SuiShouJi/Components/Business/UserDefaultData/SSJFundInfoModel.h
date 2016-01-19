//
//  SSJFundInfoModel.h
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJFundInfoModel : NSObject

//  账户ID
@property (nonatomic, copy) NSString *cfundid;

//  账户名称
@property (nonatomic, copy) NSString *cacctname;

//  图标
@property (nonatomic, copy) NSString *cicoin;

//  父账户ID(若为一级账户则父账户记为 root)
@property (nonatomic, copy) NSString *cparent;

//  颜色编号
@property (nonatomic, copy) NSString *ccolor;

//  说明
@property (nonatomic, copy) NSString *cmemo;

//  用户ID
@property (nonatomic, copy) NSString *cuserid;

//  修改\写入时间
@property (nonatomic, copy) NSString *cwritedate;

//  操作类型(0添加 1修改 2删除)
@property (nonatomic, copy) NSString *operatortype;

//  修改\写入版本
@property (nonatomic, copy) NSString *iversion;

@end
