
//
//  SSJUserItem.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserItem.h"

@implementation SSJUserItem

+ (NSDictionary *)propertyMapping {
    static NSDictionary *mapping = nil;
    if (!mapping) {
        mapping = @{@"userId":@"cuserid",
                    @"loginPWD":@"cpwd",
                    @"fundPWD":@"cfpwd",
                    @"motionPWD":@"cmotionpwd",
                    @"motionPWDState":@"cmotionpwdstate",
                    @"nickName":@"cnickid",
                    @"mobileNo":@"cmobileno",
                    @"realName":@"crealname",
                    @"idCardNo":@"cidcard",
                    @"icon":@"cicons",
                    @"registerState":@"cregisterstate",
                    @"signature":@"usersignature",
                    @"writeDate":@"cwritedate",
                    @"motionTrackState":@"cmotionPwdTrackState",
                    @"fingerPrintState":@"cfingerPrintState",
                    @"currentBooksId":@"ccurrentBooksId",
                    @"loginType":@"loginType",
                    @"openId":@"copenid",
                    @"remindSettingMotionPWD":@"remindsettingmotionpwd",
                    @"email":@"cemail",
                    @"adviceTime" : @"cadvicetime"};
    }
    return mapping;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self mj_encode:aCoder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self mj_decode:aDecoder];
     }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
//    SSJUserItem *userItem = [[SSJUserItem alloc] init];
//    userItem.userId = _userId;
//    userItem.loginPWD = _loginPWD;
//    userItem.fundPWD = _fundPWD;
//    userItem.motionPWD = _motionPWD;
//    userItem.motionPWDState = _motionPWDState;
//    userItem.nickName = _nickName;
//    userItem.mobileNo = _mobileNo;
//    userItem.realName = _realName;
//    userItem.idCardNo = _idCardNo;
//    userItem.icon = _icon;
//    userItem.registerState = _registerState;
//    userItem.signature = _signature;
//    userItem.writeDate = _writeDate;
//    userItem.motionTrackState = _motionTrackState;
//    userItem.fingerPrintState = _fingerPrintState;
//    userItem.currentBooksId = _currentBooksId;
//    userItem.loginType = _loginType;
//    userItem.openId = _openId;
//    userItem.remindSettingMotionPWD = _remindSettingMotionPWD;
//    userItem.email = _email;
//    userItem.adviceTime = _adviceTime;
//    return userItem;
    
    SSJUserItem *userItem = [[SSJUserItem alloc] init];
    [[self class] mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        id value = [self valueForKey:property.name];
        [userItem setValue:value forKey:property.name];
    }];
    return userItem;
}

- (NSString *)debugDescription {
    return [self ssj_debugDescription];
}

@end
