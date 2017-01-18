
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
                    @"registerState":@"cregisterstate",
                    @"defaultFundAcctState":@"cdefaultfundacctstate",
                    @"icon":@"cicons",
                    @"signature":@"usersignature",
                    @"writeDate":@"cwritedate",
                    @"motionTrackState":@"cmotionPwdTrackState",
                    @"fingerPrintState":@"cfingerPrintState",
                    @"currentBooksId":@"ccurrentBooksId",
                    @"loginType":@"loginType",
                    @"defaultMemberState":@"cdefaultmembertate",
                    @"defaultBooksTypeState":@"cdefaultbookstypestate",
                    @"openId":@"copenid",
                    @"remindSettingMotionPWD":@"remindsettingmotionpwd",
                    @"email":@"cemail",
                    @"adviceTime" : @"cadvicetime"};
    }
    return mapping;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_userId forKey:@"userId"];
    [aCoder encodeObject:_loginPWD forKey:@"loginPWD"];
    [aCoder encodeObject:_fundPWD forKey:@"fundPWD"];
    [aCoder encodeObject:_motionPWD forKey:@"motionPWD"];
    [aCoder encodeObject:_motionPWDState forKey:@"motionPWDState"];
    [aCoder encodeObject:_nickName forKey:@"nickName"];
    [aCoder encodeObject:_mobileNo forKey:@"mobileNo"];
    [aCoder encodeObject:_idCardNo forKey:@"idCardNo"];
    [aCoder encodeObject:_icon forKey:@"icon"];
    [aCoder encodeObject:_registerState forKey:@"registerState"];
    [aCoder encodeObject:_defaultFundAcctState forKey:@"defaultFundAcctState"];
    [aCoder encodeObject:_signature forKey:@"signature"];
    [aCoder encodeObject:_writeDate forKey:@"writeDate"];
    [aCoder encodeObject:_motionTrackState forKey:@"motionTrackState"];
    [aCoder encodeObject:_fingerPrintState forKey:@"fingerPrintState"];
    [aCoder encodeObject:_currentBooksId forKey:@"currentBooksId"];
    [aCoder encodeObject:_loginType forKey:@"loginType"];
    [aCoder encodeObject:_defaultMemberState forKey:@"defaultMemberState"];
    [aCoder encodeObject:_defaultBooksTypeState forKey:@"defaultBooksTypeState"];
    [aCoder encodeObject:_openId forKey:@"openId"];
    [aCoder encodeObject:_remindSettingMotionPWD forKey:@"remindSettingMotionPWD"];
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_adviceTime forKey:@"adviceTime"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _userId = [aDecoder decodeObjectForKey:@"userId"];
        _loginPWD = [aDecoder decodeObjectForKey:@"loginPWD"];
        _fundPWD = [aDecoder decodeObjectForKey:@"fundPWD"];
        _motionPWD = [aDecoder decodeObjectForKey:@"motionPWD"];
        _motionPWDState = [aDecoder decodeObjectForKey:@"motionPWDState"];
        _nickName = [aDecoder decodeObjectForKey:@"nickName"];
        _mobileNo = [aDecoder decodeObjectForKey:@"mobileNo"];
        _idCardNo = [aDecoder decodeObjectForKey:@"idCardNo"];
        _registerState = [aDecoder decodeObjectForKey:@"registerState"];
        _defaultFundAcctState = [aDecoder decodeObjectForKey:@"defaultFundAcctState"];
        _signature = [aDecoder decodeObjectForKey:@"signature"];
        _writeDate = [aDecoder decodeObjectForKey:@"writeDate"];
        _motionTrackState = [aDecoder decodeObjectForKey:@"motionTrackState"];
        _fingerPrintState = [aDecoder decodeObjectForKey:@"fingerPrintState"];
        _currentBooksId = [aDecoder decodeObjectForKey:@"currentBooksId"];
        _loginType = [aDecoder decodeObjectForKey:@"loginType"];
        _defaultMemberState = [aDecoder decodeObjectForKey:@"defaultMemberState"];
        _defaultBooksTypeState = [aDecoder decodeObjectForKey:@"defaultBooksTypeState"];
        _openId = [aDecoder decodeObjectForKey:@"openId"];
        _remindSettingMotionPWD = [aDecoder decodeObjectForKey:@"remindSettingMotionPWD"];
        _email = [aDecoder decodeObjectForKey:@"email"];
        _adviceTime = [aDecoder decodeObjectForKey:@"adviceTime"];
     }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJUserItem *userItem = [[SSJUserItem alloc] init];
    userItem.userId = _userId;
    userItem.loginPWD = _loginPWD;
    userItem.fundPWD = _fundPWD;
    userItem.motionPWD = _motionPWD;
    userItem.motionPWDState = _motionPWDState;
    userItem.nickName = _nickName;
    userItem.mobileNo = _mobileNo;
    userItem.realName = _realName;
    userItem.idCardNo = _idCardNo;
    userItem.icon = _icon;
    userItem.registerState = _registerState;
    userItem.defaultFundAcctState = _defaultFundAcctState;
    userItem.defaultBooksTypeState = _defaultBooksTypeState;
    userItem.defaultMemberState = _defaultMemberState;
    userItem.signature = _signature;
    userItem.writeDate = _writeDate;
    userItem.motionTrackState = _motionTrackState;
    userItem.fingerPrintState = _fingerPrintState;
    userItem.currentBooksId = _currentBooksId;
    userItem.loginType = _loginType;
    userItem.openId = _openId;
    userItem.remindSettingMotionPWD = _remindSettingMotionPWD;
    userItem.email = _email;
    userItem.adviceTime = _adviceTime;
    return userItem;
}

@end
