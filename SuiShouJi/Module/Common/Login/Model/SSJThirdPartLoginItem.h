//
//  SSJThirdPartLoginItem.h
//  SuiShouJi
//
//  Created by ricky on 16/9/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJThirdPartLoginItem : SSJBaseCellItem

@property (nonatomic,strong) NSString *openID;

// 用户昵称
@property (nonatomic,strong) NSString *nickName;

// 用户头像
@property (nonatomic,strong) NSString *portraitURL;

@property (nonatomic,strong) NSString *unionId;

// 用户性别
@property (nonatomic,strong) NSString *userGender;

// 登录方式
@property (nonatomic) SSJLoginType loginType;

@end
