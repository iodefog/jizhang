
//
//  SSJUserItem.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserItem.h"

@implementation SSJUserItem

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
    [aCoder encodeInteger:_loginType forKey:@"loginType"];
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
        _loginType = [aDecoder decodeIntegerForKey:@"loginType"];
     }
    return self;
}


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
                    @"defaultBooksType":@"cdefaultbookstype",
                    @"icon":@"cicons",
                    @"signature":@"usersignature",
                    @"writeDate":@"cwritedate",
                    @"motionTrackState":@"cmotionPwdTrackState",
                    @"fingerPrintState":@"cfingerPrintState",
                    @"currentBooksId":@"ccurrentBooksId"};
    }
    return mapping;
}

@end
