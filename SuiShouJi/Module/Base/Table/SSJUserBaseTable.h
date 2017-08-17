//
//  SSJUserBaseTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserBaseTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) NSString* fPassword;

@property (nonatomic, retain) NSString* nickName;

@property (nonatomic, retain) NSString* mobileNo;

@property (nonatomic, retain) NSString* realName;

@property (nonatomic, retain) NSString* idCardNo;

@property (nonatomic, retain) NSString* userIcon;

@property (nonatomic, assign) int registerState;

@property (nonatomic, retain) NSString* motionPassWord;

@property (nonatomic, assign) int motionPassWordState;

@property (nonatomic, retain) NSString* userSignature;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int motionPassWordTrackState;

@property (nonatomic, assign) int fingerprintState;

@property (nonatomic, retain) NSString* currentBooksId;

@property (nonatomic, assign) SSJLoginType loginType;

@property (nonatomic, retain) NSString* openId;


/**
 是否提醒过用户设置手势密码
 */
@property (nonatomic, assign) int remindSettingMotionPWD;

@property (nonatomic, retain) NSString* lastSelectFundid;

@property (nonatomic, retain) NSString* email;

@property (nonatomic, retain) NSString* adviceTime;


/**
 当前选中的资金列表
 */
@property (nonatomic, retain) NSString* currentSelectFundids;

@property (nonatomic, retain) NSString* lastSyncTime;

@property (nonatomic, retain) NSString* lastMergeTime;



WCDB_PROPERTY(userId)
WCDB_PROPERTY(password)
WCDB_PROPERTY(fPassword)
WCDB_PROPERTY(nickName)
WCDB_PROPERTY(mobileNo)
WCDB_PROPERTY(realName)
WCDB_PROPERTY(idCardNo)
WCDB_PROPERTY(userIcon)
WCDB_PROPERTY(registerState)
WCDB_PROPERTY(motionPassWord)
WCDB_PROPERTY(motionPassWordState)
WCDB_PROPERTY(userSignature)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(motionPassWordTrackState)
WCDB_PROPERTY(fingerprintState)
WCDB_PROPERTY(currentBooksId)
WCDB_PROPERTY(loginType)
WCDB_PROPERTY(openId)
WCDB_PROPERTY(remindSettingMotionPWD)
WCDB_PROPERTY(lastSelectFundid)
WCDB_PROPERTY(email)
WCDB_PROPERTY(adviceTime)
WCDB_PROPERTY(currentSelectFundids)
WCDB_PROPERTY(lastSyncTime)
WCDB_PROPERTY(lastMergeTime)

@end
