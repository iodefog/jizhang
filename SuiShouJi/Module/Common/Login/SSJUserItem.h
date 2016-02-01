//
//  SSJUserItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJUserItem : SSJBaseItem

@property (nonatomic,strong) NSString *cimei;

@property (nonatomic,strong) NSString *cuserid;

@property (nonatomic,strong) NSString *cwritedate;

@property (nonatomic,strong) NSString *isource;

@property (nonatomic,strong) NSString *istate;

@property (nonatomic,strong) NSString *operatortype;

//  手机号码
@property (nonatomic, copy) NSString *cmobileno;

//  头像地址
@property (nonatomic, copy) NSString *cicon;

@end
