//
//  SSJNewUserTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBaseTable.h"

@implementation SSJUserBaseTable

@synthesize userId;
@synthesize password;
@synthesize fPassword;
@synthesize nickId;
@synthesize mobileNo;
@synthesize nickName;
@synthesize idCardNo;
@synthesize userIcon;
@synthesize registerState;
@synthesize motionPassWord;
@synthesize motionPassWordState;
@synthesize userSignature;
@synthesize writeDate;
@synthesize motionPassWordTrackState;
@synthesize fingerprintState;
@synthesize currentBooksId;
@synthesize loginType;
@synthesize openId;
@synthesize remindSettingMotionPWD;
@synthesize lastSelectFundid;
@synthesize email;
@synthesize adviceTime;
@synthesize currentSelectFundids;
@synthesize lastSyncTime;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserBaseTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, password, "CPWD")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, fPassword, "CFPWD")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, nickId, "CNICKID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, mobileNo, "CMOBILENO")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, nickName, "CREALNAME")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, idCardNo, "CIDCARD")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, userIcon, "CICONS")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, registerState, "CREGISTERSTATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, motionPassWord, "CMOTIONPWD")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserBaseTable, motionPassWordState, "CMOTIONPWDSTATE", 0)
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, userSignature, "USERSIGNATURE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserBaseTable, motionPassWordTrackState, "CMOTIONPWDTRACKSTATE", 1)
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, fingerprintState, "CFINGERPRINTSTATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, currentBooksId, "CCURRENTBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, loginType, "LOGINTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, openId, "COPENID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, remindSettingMotionPWD, "REMINDSETTINGMOTIONPWD")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, lastSelectFundid, "LASTSELECTFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, email, "CEMAIL")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, adviceTime, "CADVICETIME")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserBaseTable, currentSelectFundids, "CCURRENTSELECTFUNDID", @"all")
WCDB_SYNTHESIZE_COLUMN(SSJUserBaseTable, lastSyncTime, "CLASTSYNCTIME")

//Primary Key
WCDB_PRIMARY(SSJUserBaseTable, userId)

@end
